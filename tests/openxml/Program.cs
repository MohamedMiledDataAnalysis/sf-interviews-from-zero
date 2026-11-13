// Checks every workbook against the Open XML schema with Microsoft's own Open XML SDK,
// the rules Excel applies when it opens a file. A file that fails here is the kind
// Excel offers to "repair". Usage: dotnet run --project tests/openxml -- excel
using System;
using System.IO;
using System.Linq;
using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Validation;

var folder = args.Length > 0 ? args[0] : "excel";
var report = new System.Text.StringBuilder();
report.AppendLine("# Workbooks checked with Microsoft's Open XML SDK (Office 2019 rules)\n");
report.AppendLine("| Workbook | Sheets | Charts | Schema errors |");
report.AppendLine("|---|---:|---:|---:|");
int total = 0;
foreach (var path in Directory.GetFiles(folder, "*.xlsx").OrderBy(p => p))
{
    using var doc = SpreadsheetDocument.Open(path, false);
    var validator = new OpenXmlValidator(FileFormatVersions.Office2019);
    var errors = validator.Validate(doc).ToList();
    var sheets = doc.WorkbookPart.WorksheetParts.Count();
    var charts = doc.WorkbookPart.WorksheetParts.Sum(w => w.DrawingsPart?.ChartParts.Count() ?? 0);
    foreach (var e in errors.Take(20))
        Console.WriteLine($"{Path.GetFileName(path)}: {e.Part?.Uri} {e.Path?.XPath}: {e.Description}");
    report.AppendLine($"| {Path.GetFileName(path)} | {sheets} | {charts} | {errors.Count} |");
    total += errors.Count;
}
Console.WriteLine(report.ToString());
Directory.CreateDirectory("tests/output");
File.WriteAllText("tests/output/OPENXML_REPORT.md", report.ToString());
return total == 0 ? 0 : 1;
