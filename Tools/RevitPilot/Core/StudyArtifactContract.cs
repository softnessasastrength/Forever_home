using System.Security.Cryptography;
using System.Text.Json;
using System.IO;

namespace ForeverHome.Pilot.Core;

/// <summary>
/// UI-neutral artifact helpers shared by desktop Revit commands and future
/// Design Automation AppBundles. No Revit API namespace is referenced.
/// </summary>
public static class StudyArtifactContract
{
    public static string Sha256File(string path)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(path);
        return Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path))).ToLowerInvariant();
    }

    public static void WriteJson<T>(string path, T value)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(path);
        ArgumentNullException.ThrowIfNull(value);
        Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(path))!);
        File.WriteAllText(path, JsonSerializer.Serialize(value, new JsonSerializerOptions { WriteIndented = true }));
    }
}
