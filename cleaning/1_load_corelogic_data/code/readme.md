## 1

- Cleaning procedure for property current
  - Load
    - load col 3, 34, 41, 48, 49, 161, 201, 202
    - ignoring headers. Add headers with cc"col_num"
    - load col 3 equate to SF counties
    - consider col 41, 201 as int
    - consider 161, 202 as float
  - Add
    - house <- if 34 start with 1
    - house_type <- s, sm, lm
    - f_ratio <- 202/161
  - export
    - a r data file to data output folder