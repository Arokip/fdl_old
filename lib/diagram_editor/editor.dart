import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_diagram_editor/diagram_editor/button/delete_all_button.dart';
import 'package:flutter_diagram_editor/diagram_editor/button/hide_menu_button.dart';
import 'package:flutter_diagram_editor/diagram_editor/button/load_diagram_from_graphml_button.dart';
import 'package:flutter_diagram_editor/diagram_editor/button/multiple_selection_switch_button.dart';
import 'package:flutter_diagram_editor/diagram_editor/button/remove_all_connections_button.dart';
import 'package:flutter_diagram_editor/diagram_editor/button/reset_view_button.dart';
import 'package:flutter_diagram_editor/diagram_editor/button/save_as_graphml_button_mobile.dart'
    if (dart.library.html) 'package:flutter_diagram_editor/diagram_editor/button/save_as_graphml_button_web.dart';
import 'package:flutter_diagram_editor/diagram_editor/button/save_as_image_button.dart';
import 'package:flutter_diagram_editor/diagram_editor/component/component_1.dart';
import 'package:flutter_diagram_editor/diagram_editor/component/component_2.dart';
import 'package:flutter_diagram_editor/diagram_editor/component/component_3.dart';
import 'package:flutter_diagram_editor/diagram_editor/component/component_common.dart';
import 'package:flutter_diagram_editor/diagram_editor/component/component_complex.dart';
import 'package:flutter_diagram_editor/diagram_editor/component/component_crystal.dart';
import 'package:flutter_diagram_editor/diagram_editor/component/component_oval.dart';
import 'package:flutter_diagram_editor/diagram_editor_library/model/canvas_model.dart';
import 'package:flutter_diagram_editor/diagram_editor_library/model/component_body.dart';
import 'package:flutter_diagram_editor/diagram_editor_library/model/custom_component_data.dart';
import 'package:flutter_diagram_editor/diagram_editor_library/model/multiple_selection_option_data.dart';
import 'package:flutter_diagram_editor/diagram_editor_library/widget/canvas.dart';
import 'package:flutter_diagram_editor/diagram_editor_library/widget/menu.dart';
import 'package:provider/provider.dart';

class Editor extends StatefulWidget {
  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  CanvasModel model = CanvasModel();

  @override
  void initState() {
    super.initState();
    initializeModel();
  }

  initializeModel() {
    fillWithBodies(model);
    generatePortRules(model);
    fillWithOptions(model);

    model.selectedPortColor = Colors.cyanAccent;
    model.otherPortsColor = Colors.teal;
    model.componentHighLightColor = Colors.deepOrange;

    model.menuData.addComponentsToMenu([
      generateComponentComplex(model),
      generateComponentCrystal(model),
      generateComponentOval(model),
      generateComponent1(model),
      generateComponent2(model, context),
      generateComponent3(model),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CanvasModel>.value(
      value: model,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            color: Colors.blueGrey,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: DiagramEditorCanvas(),
            ),
          ),
          Consumer(builder: (_, CanvasModel canvasModel, __) {
            return canvasModel.isTakingImage
                ? Container(
                    alignment: Alignment.center,
                    color: Colors.black.withOpacity(0.5),
                    child: CircularProgressIndicator(),
                  )
                : SizedBox.shrink();
          }),
          Consumer(
            builder: (_, CanvasModel canvasModel, __) {
              return Visibility(
                visible: canvasModel.menuData.isMenuVisible,
                child: Container(
                  margin: EdgeInsets.fromLTRB(2, 8, 0, 8),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 96,
                    height: 400,
                    color: Colors.black.withOpacity(0.24),
                    child: DiagramEditorMenu(
                      // scrollDirection: Axis.horizontal,
                      menuComponentRatio: MenuComponentRatio.realSizeRatio,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 24,
            bottom: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  children: [
                    HideMenuButton(),
                    SizedBox(height: 8),
                    SaveAsImageButton(),
                    SizedBox(height: 8),
                    ResetViewButton(),
                  ],
                ),
                SizedBox(width: 8),
                MultipleSelectionSwitchButton(
                  openDirection: OpenDirection.top,
                  options: [
                    MultipleSelectionOptionData(
                      icon: Icons.link_off,
                      tooltip: "Delete connections",
                      onOptionTap: model.multipleSelection.removeConnections,
                    ),
                    MultipleSelectionOptionData(
                      icon: Icons.delete_forever,
                      tooltip: "Delete",
                      onOptionTap: model.multipleSelection.removeComponents,
                    ),
                    MultipleSelectionOptionData(
                      icon: Icons.copy,
                      tooltip: "Duplicate",
                      onOptionTap: model.multipleSelection.duplicateComponents,
                    ),
                    MultipleSelectionOptionData(
                      icon: Icons.all_inclusive,
                      tooltip: "Select all",
                      onOptionTap: model.multipleSelection.selectAllComponents,
                    ),
                  ],
                ),
                SizedBox(width: 8),
                Column(
                  children: [
                    LoadDiagramFromGraphmlButton(),
                    SizedBox(height: 8),
                    SaveAsGraphmlButton(),
                    SizedBox(height: 8),
                    DeleteAllButton(),
                  ],
                ),
                SizedBox(width: 8),
                RemoveAllConnectionsButton(),
              ],
            ),
          ),
          // DEBUG:
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              color: Colors.grey,
              child: Consumer<CanvasModel>(
                builder: (_, canvasData, __) {
                  return Text(
                      'l:${canvasData.componentDataMap.length}, p:${canvasData.position}, s:${canvasData.scale}');
                },
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            right: 16,
            child: Container(
              color: Colors.grey,
              child: Consumer<CanvasModel>(
                builder: (_, canvasData, __) {
                  return Text(
                      'port rules:\n${canvasData.portRules.rules}\nmax ${canvasData.portRules.maxConnectionCount}');
                },
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, size: 16),
                  SizedBox(width: 8),
                  Text('BACK TO MENU'),
                ],
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

fillWithBodies(CanvasModel model) {
  model.addNewComponentBody(
    "body1",
    ComponentBody(
      menuComponentBody: MenuComponentBodyWidget1(),
      componentBody: ComponentBodyWidget1(),
      fromJsonCustomData: (json) => EmptyCustomComponentData.fromJson(json),
    ),
  );
  model.addNewComponentBody(
    "body2",
    ComponentBody(
      menuComponentBody: MenuComponentBodyWidget2(),
      componentBody: ComponentBodyWidget2(),
      fromJsonCustomData: (json) => MyCustomComponentData.fromJson(json),
    ),
  );
  model.addNewComponentBody(
    "body3",
    ComponentBody(
      menuComponentBody: MenuComponentBodyWidget3(),
      componentBody: ComponentBodyWidget3(),
      fromJsonCustomData: (json) => MyCustomComponentData.fromJson(json),
    ),
  );
  model.addNewComponentBody(
    "body oval",
    ComponentBody(
      menuComponentBody: MenuComponentBodyWidgetOval(),
      componentBody: ComponentBodyWidgetOval(),
      fromJsonCustomData: (json) => ExampleCustomComponentData.fromJson(json),
    ),
  );
  model.addNewComponentBody(
    "body crystal",
    ComponentBody(
      menuComponentBody: MenuComponentBodyWidgetCrystal(),
      componentBody: ComponentBodyWidgetCrystal(),
      fromJsonCustomData: (json) => MyCustomComponentData.fromJson(json),
    ),
  );
  model.addNewComponentBody(
    "body complex",
    ComponentBody(
      menuComponentBody: MenuComponentBodyWidgetComplex(),
      componentBody: ComponentBodyWidgetComplex(),
      fromJsonCustomData: (json) => MyCustomComponentData.fromJson(json),
    ),
  );
}

generatePortRules(CanvasModel model) {
  model.portRules.addRule("0", "1");
  model.portRules.addRule("0", "0");
  model.portRules.addRule("1", "1");
  model.portRules.addRules("2", ["0", "1"]);

  // portRules.canConnectSameComponent = true;

  model.portRules.setMaxConnectionCount("0", 2);
}

fillWithOptions(CanvasModel model) {
  ComponentCommon.optionsData(model).forEach((optionName, optionData) {
    model.addNewComponentOption(optionName, optionData);
  });
}
