# Optional online archive. Use from project root.
s <- read.csv("data/sources.csv", fileEncoding = "UTF-8")
dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
options(timeout = 25)
for (i in seq_len(nrow(s))) {
  is_pdf <- grepl("\\.pdf$", s$url[i], ignore.case = TRUE)
  dest <- file.path("data/raw", paste0(s$id[i], if (is_pdf) ".pdf" else ".html"))
  tmp <- tempfile(tmpdir = "data/raw")
  ok <- tryCatch({
    status <- download.file(s$url[i], tmp, mode = "wb", quiet = TRUE)
    header <- readBin(tmp, "raw", n = 5)
    status == 0 && file.size(tmp) > 500 && (!is_pdf || identical(header, charToRaw("%PDF-")))
  }, error = function(e) FALSE)
  if (ok) file.copy(tmp, dest, overwrite = TRUE)
  unlink(tmp)
  message(s$id[i], if (ok) " downloaded; inspect publisher page" else " unavailable; see source URL")
}
