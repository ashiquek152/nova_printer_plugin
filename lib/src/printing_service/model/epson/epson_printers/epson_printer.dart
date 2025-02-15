import 'package:json_annotation/json_annotation.dart';
import 'package:nova_printer_plugin/plugin.dart';
import 'package:nova_printer_plugin/src/printing_service/queue/printer_queue.dart';

part 'epson_printer.g.dart';

@JsonSerializable()
class EpsonPrinter extends Printer {
  @override
  int get characterLength => 46;
  EpsonPrinter({
    super.manufacturerName = ManufactureName.Epson,
    super.properties = const {},
  });

  factory EpsonPrinter.fromJson(Map<String, dynamic> json) {
    return _$EpsonPrinterFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$EpsonPrinterToJson(this);

  @override
  Future<PrintResult> print(PrintCommands commands) async {
    var printer = EpsonPrinterModel.fromMap(Map.from(properties));
    try {
      PrinterQueue().addToQueue(() async {
        var printResult = await NovaPrinterPlugin.onPrint(
          printer: printer,
          commands: getCommands(commands.commandList),
        );
        if (printResult != null) {
          EpsonPrinterResponse r =
              EpsonPrinterResponse.fromRawJson(printResult);
          if (!r.success) {
            return PrintResult.failed;
          }
        }
      });
      return PrintResult.success;
    } catch (e) {
      rethrow;
    }
  }
}
