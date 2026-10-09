import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final String broker = 'test.mosquitto.org';
  final String topic = 'talepuff/hardware/audio';

  Future<void> publishAudioUrl(String audioUrl) async {
    final client = MqttServerClient(broker, 'flutter_client_${DateTime.now().millisecondsSinceEpoch}');
    client.port = 1883;
    client.logging(on: false);
    client.keepAlivePeriod = 20;

    try{
      debugPrint("Connect MQTT to Broker: $broker");
      await client.connect();
    } catch (e) {
      debugPrint("MQTT failed to connect: $e");
      client.disconnect();
      return;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected){
      debugPrint("MQTT successfully connected!");

      final builder = MqttClientPayloadBuilder();
      builder.addString(audioUrl);

      debugPrint("Send message MQTT to topic '$topic': '$audioUrl'");
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

      client.disconnect();
      debugPrint("Connection MQTT closed");
    } else {
      debugPrint("Status connection MQTT failed: ${client.connectionStatus!.state}");
      client.disconnect();
    }
  }
}