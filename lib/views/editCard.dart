import 'dart:async'; //timer
import 'package:flutter/material.dart';
import '../utils/HttpUtils.dart';
import '../utils/DialogUtils.dart';
import '../utils/comUtil.dart';
import 'package:city_pickers/city_pickers.dart';
import '../globleConfig.dart';
import 'package:flutter_picker/flutter_picker.dart';
import '../model/book_cell.dart';


class editCard extends StatefulWidget {
  final BookCell card;
  editCard(this.card);

  @override
  editCardState createState() => new editCardState();
}

class editCardState extends State<editCard> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String _cardType;
  String _name;
  String _idCard;
  String _region;
  String _regionCode;
  String _phoneNo;
  String _cardExpired;


  TextEditingController _nameCtrl = TextEditingController();
  TextEditingController _cardNoCtrl = TextEditingController();
  TextEditingController _regionCtrl = TextEditingController();
  TextEditingController _bankBillCtrl = TextEditingController();
  TextEditingController _bankRepayDateCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('修改卡片信息'),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child:
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(5),
          child: Form(
            //绑定状态属性
              key: _formKey,
              autovalidate: true,
              child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widget.card.cardType == "1"
                        ? [
                      const SizedBox(height: 2.0),
                      _buildNameText(),
                      const SizedBox(height: 2.0),
                      _buildCardNoText(),
                      const SizedBox(height: 2.0),
                      _buildRegionText(),
                      const SizedBox(height: 2.0),
                      _submitButton(),
                    ]
                        : [
                      const SizedBox(height: 2.0),
                      _buildNameText(),
                      const SizedBox(height: 2.0),
                      _buildCardNoText(),
                      const SizedBox(height: 2.0),
                      _buildRegionText(),
                      const SizedBox(height: 2.0),
                      _buidbilendText(),
                      const SizedBox(height: 2.0),

                      _submitButton(),
                    ],
                  ))),
        ),
      ),
    );
  }

  // 加载进度条
  Container loadingDialog;
  // 显示加载进度条
  showLoadingDialog() {
    setState(() {
      loadingDialog = new Container(
          constraints: BoxConstraints.expand(),
          color: Color(0x80000000),
          child: new Center(
            child: new CircularProgressIndicator(),
          ));
    });
  }

  // 隐藏加载进度条
  hideLoadingDialog() {
    setState(() {
      loadingDialog = new Container();
    });
  }

  Future<bool> _checkvalue()  async{
    _idCard=widget.card.id;
    if(_idCard.isEmpty ){
      await DialogUtils.showToastDialog(context,'卡对象错误');
      return false;
    }

    final form = _formKey.currentState;
    if(form.validate())
    {
      form.save();
      return true;
    }

    return false;
  }


  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    _idCard=widget.card.id;
    _nameCtrl.text=widget.card.name;
    _cardNoCtrl.text=widget.card.cardNo;
    _bankBillCtrl.text=widget.card.bankBill;
    _bankRepayDateCtrl.text=widget.card.bankRepayDate;
    _phoneNo=widget.card.phoneNo;
    _regionCode = widget.card.citycode;
    _regionCtrl.text = widget.card.cityname;

  }


  void _forSubmitted() async{
    if (await _checkvalue()) {
      Map<String, String> params = {
        "cardId": _idCard,
        "bankBill": _bankBillCtrl.text,
        "bankRepayDate": _bankRepayDateCtrl.text,
        "regionCode": _regionCode,
        "phoneNo": _phoneNo,
      };
      try {
        showLoadingDialog();
        await HttpUtils.apipost(context, "User/cardEdit", params, (response) async{
          hideLoadingDialog();
          await DialogUtils.showToastDialog(context, response['message']);
          if (response['error_code'] == '1')
              Navigator.of(context).pop("1");
        });
      } catch (e) {
        await DialogUtils.showToastDialog(context, '网络连接错误');
      }

      hideLoadingDialog();

    }
  }

  void _showCitySelect() async {
    Result result = await CityPickers.showCityPicker(
      context: context,
    );
    print(result.cityId);
    setState(() {
      _regionCode = result.cityId;
      _region = result.cityName;
      _regionCtrl.text = _region;
    });
  }

  Widget _buildNameText() {
    return ComFunUtil().buideStandInput(context, '姓名', _nameCtrl,enable:false, valfun: (value){
      if (value.isEmpty) { return ''; }},svefun:(value) {
      _name = value.trim();
    } );

  }

  Widget _buildCardNoText() {

    return ComFunUtil().buideStandInput(context,'银行卡号',_cardNoCtrl,enable:false,iType: 'number',valfun: (value){
      if (value.isEmpty || value.trim().length <= 10) {
        return '';
      }}
      );

  }

  Widget _buildRegionText() {
    return InkWell(
      onTap: () {
        _showCitySelect();
      },
      child: ComFunUtil().buideStandInput(context, '城市', _regionCtrl ,
          valfun:(value){
            if (value.isEmpty) { return ''; }},
          svefun: (value){
            _region = value.trim();
          },tapfun: true ),
    );
  }


  Widget _buidbilendText(){

    return  new Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex:5,
            child:_buildBankBillText(),
          ),
          Expanded(
            flex:1,
            child: new SizedBox(
              width: 10.0,
            ),
          ),
          Expanded(
            flex:5,
            child: _buildEnddayText(),
          ),
        ],
      ),
    );
  }

  Widget _buildBankBillText() {

    return InkWell(
      onTap: () {
        showPickerNumber(context, _bankBillCtrl);
      },
      child: ComFunUtil().buideStandInput(context, '账单日', _bankBillCtrl ,
          valfun:(value){
            if (value.isEmpty) { return ''; }}
          ,tapfun: true ),
    );
  }

  Widget _buildEnddayText() {

    return InkWell(
      onTap: () {
        showPickerNumber(context, _bankRepayDateCtrl);
      },
      child: ComFunUtil().buideStandInput(context, '还款日', _bankRepayDateCtrl ,
          valfun:(value){
            if (value.isEmpty) { return ''; }},
          tapfun: true ),
    );

  }

  Widget _submitButton() {
    return FlatButton(
      color: GlobalConfig.mainColor,
//            child: Padding(
//              padding: EdgeInsets.all(5),
      child: Text(
        '确认修改',
        style: new TextStyle(color: Colors.white, fontSize: 14.0),
      ),
//            ),
      onPressed: () {
        _forSubmitted();
      },
    );
  }

  showPickerNumber(BuildContext context,  TextEditingController ctrtext) {
    new Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(begin: 1, end: 31),
        ]),
        hideHeader: true,
        title: new Text("日期选择"),
        cancelText: '取消',
        confirmText: '确定',
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print(picker.getSelectedValues());
          setState(() {
            ctrtext.text=picker.getSelectedValues()[0].toString();

          });
        }).showDialog(context);
  }

  showPickermmyy(BuildContext context, TextEditingController ctrtext) {
    new Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(begin: 1, end: 31),
          NumberPickerColumn(begin: 19, end: 50),
        ]),
        hideHeader: true,
        title: new Text("有效期选择"),
        cancelText: '取消',
        confirmText: '确定',
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print(picker.getSelectedValues());
          setState(() {
            _cardExpired ='${picker.getSelectedValues()[0].toString().padLeft(2, '0')}${picker.getSelectedValues()[1].toString()}';
            ctrtext.text = _cardExpired;
            print(_cardExpired);
          });
        }).showDialog(context);
  }

}
