import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_diagram_editor/diagram_editor_library/model/custom_component_data.dart';
import 'package:flutter_diagram_editor/diagram_editor_library/model/port_data.dart';
import 'package:uuid/uuid.dart';

class ComponentData extends ChangeNotifier {
  String id;
  Offset position;
  Size size;
  final Size minSize;
  final double portSize;

  final List<PortData> portList;
  HashMap<String, PortData> ports = HashMap<String, PortData>();

  final double optionSize;
  final List<String> topOptions;
  final List<String> bottomOptions;

  bool enableResize = false;

  final CustomComponentData customData;

  final String componentBodyName;

  ComponentData({
    this.id,
    this.position = Offset.zero,
    this.size = const Size(80, 80),
    this.minSize = const Size(32, 32),
    this.portSize = 20,
    this.portList = const [],
    this.optionSize = 40,
    this.topOptions = const [],
    this.bottomOptions = const [],
    this.customData = const EmptyCustomComponentData(),
    @required this.componentBodyName,
  })  : assert(minSize <= size),
        assert(position != null),
        assert(size != null),
        assert(portSize != null),
        assert(portSize > 0),
        assert(portList != null),
        assert(topOptions != null),
        assert(bottomOptions != null),
        assert(customData != null),
        assert(componentBodyName != null),
        assert(portList.map((e) => e.id).length ==
            portList.map((e) => e.id).toSet().length) {
    if (id == null) {
      id = Uuid().v4();
    }
    for (int i = 0; i < portList.length; i++) {
      portList[i].setComponentId(id);
      ports[portList[i].id] = portList[i];
    }
  }

  componentUpdateData() {
    print('component notify update');
    notifyListeners();
  }

  updatePosition(Offset position) {
    this.position += position;
    notifyListeners();
  }

  addPort(PortData portData) {
    ports[portData.id] = portData;
  }

  Offset getPortCenterPoint(String portId) {
    var componentCenter = size.center(Offset.zero);
    var portCenter = Offset(portSize / 2, portSize / 2);

    var portPosition = Offset(
      componentCenter.dx * ports[portId].alignment.x,
      componentCenter.dy * ports[portId].alignment.y,
    );

    return position + componentCenter + portCenter + portPosition;
  }

  String getPortIdFromLink(String linkId) {
    String resultPortId;
    ports.forEach((String portId, PortData port) {
      port.connections.forEach((connection) {
        if (connection.connectionId == linkId) {
          resultPortId = portId;
          return;
        }
      });
      if (resultPortId != null) {
        return;
      }
    });
    return resultPortId;
  }

  removeConnection(String connectionId) {
    ports.values.forEach((port) {
      port.removeConnection(connectionId);
    });
  }

  ComponentData duplicate({Offset offset = const Offset(0, 0), String newId}) {
    final List<PortData> newPorts = [];

    ports.values.forEach((port) {
      newPorts.add(port.duplicate());
    });

    return ComponentData(
      id: newId,
      size: Size(size.width, size.height),
      portSize: portSize,
      portList: newPorts,
      topOptions: List<String>.from(topOptions),
      bottomOptions: List<String>.from(bottomOptions),
      position: position + offset,
      customData: customData.duplicate(),
      componentBodyName: componentBodyName,
    );
  }

  switchEnableResize() {
    enableResize = !enableResize;
    notifyListeners();
  }

  resizeDelta(Offset deltaSize, updateLinkMap) {
    var tempSize = size + deltaSize;
    if (tempSize.width < minSize.width) {
      tempSize = Size(minSize.width, tempSize.height);
    }
    if (tempSize.height < minSize.height) {
      tempSize = Size(tempSize.width, minSize.height);
    }
    size = tempSize;
    updateLinkMap(this.id);
    notifyListeners();
  }

  @override
  String toString() {
    return 'Component data ($id), position: $position, ports: $ports';
  }
}
