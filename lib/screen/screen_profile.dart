import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hobbybase/model/User.dart';
import 'package:hobbybase/widget/dialog_widget.dart';

import 'package:country_pickers/country_pickers.dart';

class Profile extends StatefulWidget {
  User user = User();
  Profile(this.user);

  @override
  _ProfileState createState() => _ProfileState(this.user);
}

class _ProfileState extends State<Profile> {
  User user = User();
  _ProfileState(this.user);

  Country _selectedCupertinoCountry = CountryPickerUtils.getCountryByIsoCode('TH'); // Default area(country)

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(user.area != '') {
      _selectedCupertinoCountry = CountryPickerUtils.getCountryByIsoCode(user.area);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(10.0,0,10.0,0),

        child: ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Image.asset(
                    "assets/rank/rank_01.jpg",
                    fit: BoxFit.cover,
                    width: 100.0,
                    height: 100.0,
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 5.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            onTap: (){
                              debugPrint("Do logoff");
                              DialogUtils().showConfirmationDialog(context,
                                  'Sign Out',
                                  'Are you sure you would like to sign out?',
                                  'Sign out',
                                  'Cancel',
                                  'sign_out',
                                  'close_dialog'
                              );
                            },
                            child: Text("Logout",
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).accentColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                  flex: 3,
                ),
              ],
            ),

            Divider(),
            Container(height: 15.0),

            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                "Account Information".toUpperCase(),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // User Display Name
            Card(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 15.0, top: 10.0),
                          child: Text(
                            'User Display Name',
                            style: TextStyle(
                              fontFamily: 'K2D-Bold',
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
                          child: Text(
                            user.name,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontFamily: 'K2D-Light',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,

                      child: Padding(
                        padding: EdgeInsets.only(right: 15.0),
                        child:  IconButton(
                          icon: Opacity(
                            opacity: 0.5,
                            child:  Icon(
                              Icons.edit,
                              size: 20.0,
                            ),
                          ),
                          onPressed: (){
                            debugPrint("Edit User Display Name");
                            DialogUtils().showEditTextDialog(context,
                                'Edit User Display Name',
                                user.name,
                                'OK',
                                'Cancel',
                                'save_user_display_name',
                                user.uid,
                                user
                            ).then((value) => getUserData());

                          },
                          tooltip: "Edit",
                        ),
                      ),
                    ),
                  ]
              ),
            ),

            // Email
            Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 15.0, top: 10.0),
                        child: Text(
                          'Email',
                          style: TextStyle(
                            fontFamily: 'K2D-Bold',
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
                        child: Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontFamily: 'K2D-Light',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,

                    child: Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child:  IconButton(
                        icon: Opacity(
                          opacity: 0.5,
                          child:  Icon(
                              Icons.edit,
                              size: 20.0,
                            ),
                        ),
                        onPressed: (){
                          print('edit email!');
                          DialogUtils().showEditTextDialog(context,
                              'Edit Email',
                              user.email,
                              'OK',
                              'Cancel',
                              'save_user_email',
                              user.uid,
                              user
                          ).then((value) => getUserData());
                        },
                        tooltip: "Edit",
                      ),
                    ),
                  ),
                ]
              ),
            ),

            // Country Area
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 10.0),
                    child:
                    Text('Area',
                      style: TextStyle(
                        fontFamily: 'K2D-Bold',
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  ListTile(
                    title: _buildCupertinoSelectedItem(_selectedCupertinoCountry),
                    onTap: _openCupertinoCountryPicker,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
      _useCustomBottomNavigationBar(),
    );
  }

  Widget _buildCupertinoSelectedItem(Country country) {
    return Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
//        SizedBox(width: 8.0),
//        Text("+${country.phoneCode}"),
        SizedBox(width: 8.0),
        Flexible(child: Text(country.name))
      ],
    );
  }

  Widget _buildCupertinoItem(Country country) {
    return DefaultTextStyle(
      style: const TextStyle(
        color: CupertinoColors.white,
        fontSize: 16.0,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 8.0),
          CountryPickerUtils.getDefaultFlagImage(country),
          SizedBox(width: 8.0),
          Text("+${country.phoneCode}"),
          SizedBox(width: 8.0),
          Flexible(child: Text(country.name))
        ],
      ),
    );
  }

  void _openCupertinoCountryPicker() => showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return CountryPickerCupertino(
          backgroundColor: Colors.black,
          itemBuilder: _buildCupertinoItem,
          pickerSheetHeight: 200.0,
          pickerItemHeight: 75,
          initialCountry: _selectedCupertinoCountry,
          onValuePicked: (Country country) =>  {
//
            setState(() {
              _selectedCupertinoCountry = country;
            }),
          },
          priorityList: [
            CountryPickerUtils.getCountryByIsoCode('TH'),
            CountryPickerUtils.getCountryByIsoCode('DE'),
          ],
        );
      });

  _tapBack() {
    print('tap on back');
    updateUserAreaDB(user.uid, _selectedCupertinoCountry.isoCode).then((value) => Navigator.pop(context, 'back'));

  }

  Widget _useCustomBottomNavigationBar() {
    return Container(
      height: 60,
//      color: Colors.black87,
      child: InkWell(
        onTap: () => {
          _tapBack()
        },
        child: Padding(
          padding: EdgeInsets.only( top: 8.0),
          child: Column(
            children: <Widget>[
              Icon(
                Icons.arrow_back,
                color: Theme.of(context).accentColor,
              ),
              Text('Back',
                style: TextStyle(
                  fontFamily: 'K2D-Regular',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getUserData() {
    User.getUserDB(user.uid).then((userdb) {
      print('--- Current user is ${user.toString()} ---');
      setState(() {
        user = userdb;
//        _userName = user.name;
      });
    });
  }

  Future<User> updateUserAreaDB(String uid, String area) async {
    print('call updateUserAreaDB(uid[${uid}], area[${area}])');
    try {
      User user = new User(
        uid: uid,
        area: area,
      );
      var db = Firestore.instance;

      await db.collection("users")
          .document(uid)
          .setData({
        'area': user.area,

        'updated_when': Timestamp.now(),
        'updated_by': user.uid,
      }, merge: true).then((_) {
        print('success');

      });

      return user;
    } on Exception catch(err) {
      print('Update user area error: $err');
      return User();
    } finally {

      print('End of updateUserAreaDB()');
    }
  }

}