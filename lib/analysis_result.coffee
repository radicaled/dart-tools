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
    result.line     = segments[4]
    result.column   = segments[5]
    result.length   = segments[6]
    result.desc     = segments[7]
    return result
