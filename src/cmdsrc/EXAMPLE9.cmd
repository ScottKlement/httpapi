CMD PROMPT('Convert HTML to PDF')

PARM KWD(URL) TYPE(*CHAR) MIN(1) +
     LEN(5000) VARY(*YES) EXPR(*YES) +
     CHOICE('URL') +
     PROMPT('URL to convert to PDF')

PARM KWD(STMF) TYPE(*PNAME) MIN(1) +
     LEN(5000) VARY(*YES) EXPR(*YES) +
     PROMPT('IFS Stream file to Save')

PARM KWD(FMT) TYPE(*CHAR) +
     LEN(5) EXPR(*YES) RSTD(*YES) +
     SPCVAL((*JSON) (*PDF) (*PNG)) DFT(*PDF) +
     PROMPT('Format to convert to')
