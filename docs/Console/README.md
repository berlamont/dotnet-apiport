# .NET Portability Analyzer (Console application)

The console tool helps you determine how flexible your application.  The tool 
understands the following commands:

  * `ApiPort.exe analyze <options>`
    * Analyzes the portability of an application
    * [Examples](#apiportexe-analyze-scenarios)
  * `ApiPort.exe listTargets`
    * Lists .NET platforms available for analysis
  * `ApiPort.exe listOutputFormats`
    * Lists available report output formats
  * `ApiPort.exe DocIdSearch <options>`
    * Searches for matching docIds

## `ApiPort.exe analyze` Scenarios

Arguably the most important function of the tool is its ability to analyze an 
assembly. This can take in a file, collection of files, or a directory of 
assemblies.  

**Analyzing a file against specific targets and outputting an HTML report**

```
ApiPort.exe analyze -f Foo.dll -t ".NET Framework, Version=4.6.2" -t 
".NET Standard, Version=1.6" -r HTML -o AnalysisReport.html
```

The `-f` flag followed by a path represents the file or directory that the
analysis should be performed on; in this case, it is `Foo.dll`.  The multiple
uses of `-t` followed by target names tells the tool what .NET platforms we want
to analyze the input assembly(ies) against. `-r` is the output format of the
report. `-o` is the output name for that report.  

So, our analysis will be performed on `Foo.dll` against 
`.NET Framework, Version=4.6.2` and `.NET Standard, Version=1.6` and output as
an HTML file, `AnalysisReport.html`.

**Analyzing a directory against the default targets and outputting default 
report format**

```
ApiPort.exe analyze -f C:\git\Application\bin\Debug
```

This will analyze all assemblies that exist under `C:\git\Application\bin\Debug`
recursively, and analyzes those assemblies against the default .NET platforms. 
(**Note:** The default platforms can be obtained by running `ApiPort.exe 
listTargets` and looking for targets that have an (\*) in them.)

**Analyzing a directory and show breaking changes**

```
ApiPort.exe analyze -f C:\git\Application\bin\Debug -b
```

The `-b` flag will show any APIs that may have different behavior between 
versions of .NET Framework due to breaking changes that have been made.  The 
entire list of breaking changes in .NET Framework can be found by examining 
[Application Compatibility in the .NET Framework][Breaking Changes]. For the 
list of breaking changes we analyze against, look [here](BreakingChanges.md).

**Analyzing a directory and show any non-portable APIs**

```
ApiPort.exe analyze -f C:\git\Application\bin\Debug -p
```

The `-p` flag will highlight any APIs that are not portable against the default
target .NET platforms. (No explicit `-t` arguments were specified, so we use the
default targets.)

## Using .NET Core application

The portability analyzer has a version that targets .NET Core. Possible reasons
for using the .NET Core application include:

* Working on machine without .NET Framework 4.6 installed
* Working on a non-Windows OS

### Compiling, Debugging and Running

**From Commandline**

1. Execute `build.cmd`
2. Go to `bin\Release\ApiPort.Core\netcoreapp1.0`
3. Go to either `x64` or `x86` folder
4. Execute `dotnet.exe ApiPort.exe`

**In Visual Studio 2015**

1. Change **Platform** to `x64` or `x86`
2. Compile solution
3. Set `ApiPort.Core` as Start-up Project
4. Start debugging (F5)

### Troubleshooting

**Problem: The program can't start because api-ms-win-crt-runtime-l1-1-0.dll is missing
from your computer.**

Solution: Install [Visual Studio 2015 C++ Redistributable][VS2015 C++ Redistributable].

## Alternate modes

The tool by default will gather the results and submit to a webservice that will
analyze the data to determine which APIs need to be addressed. For full details
on this process, please read the [privacy policy][Privacy Policy].  There are 
two alternate modes that can be used to alter this workflow. 

### See the data being transmitted

The first option is to output the request to a file. This will result in an 
output that shows what data is being transmitted to the service, but provides no
details as to API portability or breaking changes. This is a good option if you
would like to see what data will be collected.

In order to enable this mode, create a file `autofac.json` and place it in the
same directory as `ApiPort.exe`. Add the following contents:

```json
{
  "defaultAssembly": "ApiPort",
  "modules": [
    {
      "type": "ApiPort.Modules.DataTransferModule"
    }
  ]
}
```

Now, when you run, it will output a file (ie. `ApiPortAnalysis.json`) with the information that is sent to 
the .NET Portability service.

### Run the tool in an offline mode

Another option is to enable full offline access. This mode will not get 
automatic updates and no official releases of it are available. In order to use
this mode, the solution must be manually built. To do so, please follow these
steps:

1. Clone the project: `git clone https://github.com/Microsoft/dotnet-apiport`
2. Build the project: `build.cmd`. 

    *Note: This command must be used as it gathers the correct assemblies for offline mode. Building in VS does not do this.*
    
3. Go to `bin\release\ApiPort.Offline`
4. Run `ApiPort.exe` from this directory as normal.

If you have issues with proxies, please add your proxy information to the catalog script:

1. Edit [`.\build\Get-CatalogFile.ps1` at line 24](https://github.com/Microsoft/dotnet-apiport/blob/master/build/Get-CatalogFile.ps1#L24)
2. Replace Line 24 with: 
  - If your proxy uses your default credentials: `Invoke-WebRequest $url -OutFile $OutputPath -Proxy [Proxy Address] -ProxyUseDefaultCredentials`
  - Otherwise: `Invoke-WebRequest $url -OutFile $OutputPath -Proxy [Proxy Address] -ProxyCredential [Credentials]` 
3. Run `build.cmd` 

Additional reports can be generated in offline mode. Any implementation of `Microsoft.Fx.Portability.Reporting.IReportWriter` can be
used. An assembly with the name of `Microsoft.Fx.Portability.Writers.[NAME].dll` will be searched for any available implementations.

Note that offline mode is not supported for .NET Core versions of ApiPort.

[Breaking Changes]: https://msdn.microsoft.com/en-US/library/dn458358(v=vs.110).aspx
[Issue #2311]: https://github.com/dotnet/cli/issues/2311
[Privacy Policy]:/docs/LicenseTerms/Microsoft%20.NET%20Portability%20Analyzer%20Privacy%20Statement.txt
[VS2015 C++ Redistributable]: https://www.microsoft.com/en-us/download/details.aspx?id=53587
