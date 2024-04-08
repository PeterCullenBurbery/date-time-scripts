function Get-ISO8601Week {
  [CmdletBinding()]
  param(
    [Parameter(
      ValueFromPipeline                =  $true,
      ValueFromPipelinebyPropertyName  =  $true
    )]                                           [datetime]  $DateTime
  )
  process {
    foreach ($_DateTime in $DateTime) {
      $_DayOfWeek      =  $_DateTime.DayOfWeek.value__

      # In the underlying object, Sunday is always 0 (Monday = 1, ..., Saturday = 6) irrespective of the FirstDayOfWeek settings (Sunday/Monday)
      # Since ISO 8601 week date (https://en.wikipedia.org/wiki/ISO_week_date) is Monday-based, flipping Sunday to 7 and switching to one-based numbering.
      if ($_DayOfWeek  -eq  0) {
        $_DayOfWeek =    7
      }

      # Find the Thursday from this week:
      #     E.g.: If original date is a Sunday, January 1st     , will find     Thursday, December 29th     from the previous year.
      #     E.g.: If original date is a Monday, December 31st   , will find     Thursday, January 3rd       from the next year.
      $_DateTime                 =  $_DateTime.AddDays((4  -  $_DayOfWeek))

      # The above Thursday it's the Nth Thursday from it's own year, wich is also the ISO 8601 Week Number
      $_WeekNumber  =  [math]::Ceiling($_DateTime.DayOfYear    /   7)

      # The format requires the ISO week-numbering year and numbers are zero-left-padded (https://en.wikipedia.org/wiki/ISO_8601#General_principles)
      # It's also easier to debug this way :)
      $_WeekString  =  "$($_DateTime.Year)-W$("$_WeekNumber".PadLeft(2,  '0'))-$_DayOfWeek"
      Write-Output                  $_WeekString
    }
  }
}
# Define the start and end dates
$StartDate = Get-Date -Year 2002 -Month 2 -Day 18
$EndDate = Get-Date -Year 2122 -Month 2 -Day 18

# Define the directory where you want to create the files
$DirectoryPath = '\\vmware-host\Shared Folders\four-terabyte-hard-drive\journal'

# Loop through each day between the start and end dates
for ($Date = $StartDate; $Date -le $EndDate; $Date = $Date.AddDays(1)) {
    # Check if the current date exceeds the end date
    if ($Date -gt $EndDate) {
        break
    }

    # Format the date as a string in ISO week date format
    $DateTimeString = Get-ISO8601Week -DateTime $Date

    # Construct the full path for the file
    $FilePath = Join-Path -Path $DirectoryPath -ChildPath "$DateTimeString.txt"
    
    # Check if the file already exists
    if (-not (Test-Path -Path $FilePath)) {
        # Create the file
        New-Item -Path $FilePath -ItemType File
    }
}
