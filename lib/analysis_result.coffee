module.exports =
class AnalysisResult
  # processes dartanalyzer output in the form of:
  # INFO|HINT|USE_OF_VOID_RESULT|/home/arron/bar.dart|22|52|6|SomeText
  # INFO: type, HINT: subtype, USE_OF_VOID_RESULT: really specific type
  # 22: line, 55: column, 6: length
  @fromDartAnalyzer: (line) ->
    segments = line.split('|')
    result = new AnalysisResult
    result.category = segments[0]
    result.subtype  = segments[1]
    result.detail   = segments[2]
    result.fullpath = segments[3]
    result.line     = parseInt segments[4]
    result.column   = parseInt segments[5]
    result.length   = parseInt segments[6]
    result.desc     = segments[7]
    return result
