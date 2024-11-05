/// DashboardPage stub
String stubLaravelDashboard() => '''
import 'package:flutter/material.dart';
import '/app/events/logout_event.dart';
import '/app/models/user.dart';
import '/app/networking/laravel_api_service.dart';
import '/bootstrap/extensions.dart';
import '/bootstrap/helpers.dart';
import 'package:nylo_framework/nylo_framework.dart';

class DashboardPage extends NyStatefulWidget {
  static RouteView path = ("/dashboard", (_) => DashboardPage());

  DashboardPage() : super(child: () => _DashboardPageState());
}

class _DashboardPageState extends NyState<DashboardPage> {

  User? _user;

  @override
  get init => () async {
    _user = await api<LaravelApiService>((request) => request.user());
  };
  
  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: "ebf0f4".toHexColor(),
      appBar: AppBar(
        title: Text("Dashboard").setColor(context, (color) => Colors.black),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SafeArea(
         child: afterLoad(child: () => Container(
           padding: EdgeInsets.all(16),
           decoration: BoxDecoration(
             borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
             color: Colors.white
           ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.center,
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Column(
                 children: [
                   Container(
                     margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                     padding: EdgeInsets.all(15),
                     decoration: BoxDecoration(
                         color: ThemeColor.get(context).background,
                         borderRadius: BorderRadius.circular(8),
                         boxShadow: [
                           BoxShadow(
                               color: Colors.grey.shade200,
                               spreadRadius: 0.1,
                               blurRadius: 20
                           )
                         ]),
                     child: Icon(Icons.key),
                   ),
                   Text("Logged in").headingMedium(),
                   Divider(),
                   Text("Auth: \${_user?.email}"),
                 ],
               ),
               Container(
                 margin: EdgeInsets.only(top: 20),
                 width: double.infinity,
                 child: MaterialButton(
                   child: Text("Logout"), onPressed: () async {
                     event<LogoutEvent>();
                     await Auth.logout();
                     routeToInitial();
                 },),
               )
             ],
           ),
         ),)
      ),
    );
  }
}
''';
