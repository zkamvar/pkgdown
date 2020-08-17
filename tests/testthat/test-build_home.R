context("test-build_home.R")

# index -------------------------------------------------------------------

test_that("intermediate files cleaned up automatically", {
  skip_if_no_pandoc()

  pkg <- test_path("assets/home-index-rmd")
  expect_output(build_home(pkg))
  on.exit(clean_site(pkg))

  expect_setequal(dir(pkg), c("docs", "DESCRIPTION", "index.Rmd"))
})

test_that("intermediate files cleaned up automatically", {
  skip_if_no_pandoc()

  pkg <- test_path("assets/home-readme-rmd")
  expect_output(build_home(pkg))
  on.exit(clean_site(pkg))

  expect_setequal(
    setdiff(dir(pkg), "man"),
    c("docs", "NAMESPACE", "DESCRIPTION", "README.md", "README.Rmd")
  )
})

test_that("can build site even if no Authors@R present", {
  skip_if_no_pandoc()

  pkg <- test_path("assets/home-old-skool")
  expect_output(build_home(pkg))
  on.exit(clean_site(pkg))
})

# .github files -----------------------------------------------------------

test_that(".github files are copied and linked", {
  skip_if_no_pandoc()
  # .github in this test is build-ignored to prevent a NOTE about an unexpected
  # hidden directory. Skip on CMD CHECK if the .github directory is not present.
  pkg <- test_path("assets/site-dot-github")
  skip_if_not(dir_exists(path(pkg, ".github"))[[1]])

  on.exit(clean_site(pkg))
  expect_output(build_home(pkg))

  lines <- read_lines(path(pkg, "docs", "index.html"))
  expect_true(any(grepl('href="CODE_OF_CONDUCT.html"', lines)))
  expect_true(file_exists(path(pkg, "docs", "404.html")))
})

# extra md files ----------------------------------------------------------

test_that("home md files are copied", {
  skip_if_no_pandoc()
  pkg <- test_path("assets/home-md")
  skip_if_not(file_exists(path(pkg, "extra.md"))[[1]])

  on.exit(clean_site(pkg))
  expect_output(build_home(pkg))

  expect_true(file_exists(path(pkg, "docs", "extra.html")))
  expect_true(file_exists(path(pkg, "docs", "index.html")))

  # The index is identical to the README
  idx  <- xml2::read_html(path(pkg, "docs", "index.html"))
  expect_true(xml2::xml_find_lgl(idx, "boolean(.//h1[text()='Test'])"))

  # Bug fix items should be in a custom div class called 'buggin'
  # This will fail using pandoc with markdown_github
  html <- xml2::read_html(path(pkg, "docs", "extra.html"))
  handles <- xml2::xml_find_all(html, ".//div[@class='buggin']/ul/*")
  expect_length(handles, 2L)

})
