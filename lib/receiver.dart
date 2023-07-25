import 'dart:io';

void main(List<String> args) async {
  const localhost = '127.0.0.1';
  const port = 16000;
  const receiverPort = 16001;
  final udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);

  udpSocket.listen((data) {
    final datagram = udpSocket.receive();
    if (datagram != null) {
      print(
          '\nRecibiendo de ${datagram.address.address}:${datagram.port} : ${String.fromCharCodes(datagram.data)}\n');
      _sendMessage(udpSocket, localhost, receiverPort);
    }
  });

  _sendMessage(udpSocket, localhost, receiverPort);
}

_sendMessage(RawDatagramSocket socket, String address, int port) {
  stdout.write('Escribe el mensaje que quieras enviar: ');
  final message = stdin.readLineSync() ?? '';
  socket.send(message.codeUnits, InternetAddress(address), port);
}
