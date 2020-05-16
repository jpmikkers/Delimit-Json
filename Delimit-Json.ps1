<#
.Synopsis
    Splits text consisting of concatenated JSON objects into separate JSON chunks.

.DESCRIPTION
    Splits text consisting of concatenated JSON objects into separate JSON chunks.
    This is useful for processing JSON structured logging.

.EXAMPLE  
    Get-Content -Wait "jsonstructuredlog.txt" | Delimit-Json | %{ "New structured log object: $($_ | ConvertFrom-Json)" }

    This will act as tail-like monitoring for a json structured log file, showing new objects as soon 
    as they are appended and complete.
#>
function Delimit-Json
{
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline)]
        [string]$concatenated
    )
    Begin
    {
        $reconstructed = ""
        $betweenQuotes = $false
        $braceLevel = 0
        $squareLevel = 0
    }
    Process
    {
        # split by square brackets, braces and quotes.
        $concatenated -split '([\{\}\[\]\"])' |
        where { $_.Length -gt 0 } | 
        foreach {
            # reassemble the json object in progress
            $reconstructed += $_

            # update the $betweenQuotes state
            if($betweenQuotes)
            {
                # only end if the last character was a non-escaped double quote
                if($reconstructed[-1] -eq '"' -and $reconstructed[-2] -ne '\'){ $betweenQuotes = $false }
            }
            else
            {
                if($reconstructed[-1] -eq '"'){ $betweenQuotes = $true }
            }

            # only look at nesting levels if we did not end somewhere within double quoted string
            if(!$betweenQuotes)
            {
                $lastChar = $reconstructed[-1]
                $checkTerminal = $false

                if($lastChar -eq '{'){ $braceLevel+=1 } 
                elseif($lastChar -eq '['){ $squareLevel+=1 } 
                elseif($lastChar -eq '}'){ $braceLevel-=1; $checkTerminal=$true }
                elseif($lastChar -eq ']'){ $squareLevel-=1; $checkTerminal=$true }

                if($checkTerminal -and $braceLevel -eq 0 -and $squareLevel -eq 0)
                {
                    $reconstructed
                    $reconstructed = ""
                }
            }
        }
    }
    End
    {
    }
}
