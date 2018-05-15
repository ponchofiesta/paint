import 'dart:async';

import 'package:angular/angular.dart';
//import 'package:angular_components/angular_components.dart';

import 'paint_service.dart';

@Component(
  selector: 'paint',
  styleUrls: const ['paint_component.css'],
  templateUrl: 'paint_component.html',
  directives: const [
    CORE_DIRECTIVES
  ],
  providers: const [PaintService],
)
class PaintComponent implements OnInit {
  final PaintService paintService;

  PaintComponent(this.paintService);

  @override
  Future<Null> ngOnInit() async {

  }

}
