inclusionLevelsFormat <- function() {
    list(
        tablename   = "Inclusion levels", # Name of the created table
        description = "Exon and intron inclusion levels for any given alternative splicing event.",
        dataType    = "Inclusion levels", # General category for the data
        
        # Transpose the data? This is the first step before parsing the information!
        # After transposition, a row of the current data equals a column of the original
        transpose   = FALSE,
        
        # Format checker information
        rowCheck    = TRUE,  # Check format using a row (TRUE) or a column (FALSE)
        checkIndex  = 1,     # Index of the row or column used to check the format
        
        # File string to check
        check = c("Inclusion levels"),
        
        # Parsing information
        delim       = "\t",  # Delimiter used to separate fields
        colNames    = 1,     # Row to use for column names
        rowNames    = 1,     # Column to use for row names
        ignoreCols  = NULL,  # Columns to ignore
        ignoreRows  = NULL,  # Rows to ignore
        commentChar = NULL,  # String to identify comments (these lines will be ignored)
        
        # Other options
        unique = FALSE,   # Remove duplicated rows
        
        # Default columns to show (NULL to show all)
        show = NULL,
        process = NULL
    )
}

attr(inclusionLevelsFormat, "loader") <- "formats"