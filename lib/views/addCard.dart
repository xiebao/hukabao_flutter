import 'dart:async'; //timer
import 'package:flutter/material.dart';
import '../utils/HttpUtils.dart';
import '../utils/DialogUtils.dart';
import '../utils/comUtil.dart';
import 'package:city_pickers/city_pickers.dart';
import '../globleConfig.dart';
import 'package:flutter_picker/flutter_picker.dart';

class addCard extends StatefulWidget {
  final String cardType;
  final String userName;
  final String UserIdNo;
  addCard({Key key, @required this.cardType,this.userName,this.UserIdNo}) : super(key: key);

  @override
  addCardState createState() => new addCardState();
}

class addCardState extends State<addCard> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String _cardType;
  String _name;
  String _idCard;
  String _cardNo;
  String _bankName;
  String _bankId;
  String _region;
  String _regionCode;
  String _branch;
  String _phoneNo;

  String _cardCvn2;
  String _cardExpired;
  String _bankBill;
  String _bankRepayDate;
  String _orderNo;
  String _smsSeq;

  int _seconds = 0;
  bool _getsmscode=false;
  String _verifyStr = '获取验证码';
  String _verifyCode;
  Timer _timer;

  List<String> _bankPickerData = new List();
  var _bankCodeMap = {}; //Map<String,String>

  TextEditingController _nameCtrl = TextEditingController();
  TextEditingController _idCardCtrl = TextEditingController();
  TextEditingController _cardNoCtrl = TextEditingController();
  TextEditingController _branchCtrl = TextEditingController();


  TextEditingController _bankIdCtrl = TextEditingController();
  TextEditingController _regionCtrl = TextEditingController();
  TextEditingController _cardExpiredCtrl = TextEditingController();
  TextEditingController _bankBillCtrl = TextEditingController();
  TextEditingController _bankRepayDateCtrl = TextEditingController();

  TextEditingController _phoneNoCtrl = TextEditingController();
  TextEditingController _verifyCodeCtrl = TextEditingController();

  TextEditingController _cardCvn2Ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('添加卡片'),
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
                    children: widget.cardType == "1"
                        ? [
                     const SizedBox(height: 2.0),
                            _buildNameText(),
                     const SizedBox(height: 2.0),
                            _buildIdcardText(),
                     const SizedBox(height: 2.0),
                            _buildCardNoText(),
                     const SizedBox(height: 2.0),
                            _buildBankIdText(),
                     const SizedBox(height: 2.0),
                            _buildRegionText(),
//                     const SizedBox(height: 2.0),
//                            _buildBranchText(),
                     const SizedBox(height: 2.0),
                            _buildPhoneText(),
                     const SizedBox(height: 2.0),
                            _buildVerifyCodeEdit(),
                     const SizedBox(height: 2.0),
                            _submitButton(),
                          ]
                        : [
                     const SizedBox(height: 2.0),
                            _buildNameText(),
                     const SizedBox(height: 2.0),
                            _buildIdcardText(),
                     const SizedBox(height: 2.0),
                            _buildCardNoText(),
                     const SizedBox(height: 2.0),
                            _buildBankIdText(),
                     const SizedBox(height: 2.0),
                            _buildRegionText(),
                   /*  const SizedBox(height: 2.0),
                            _buildBranchText(),*/

                     const SizedBox(height: 2.0),
                     _buidbilendText(),
                     const SizedBox(height: 2.0),
                     _buidExdymmyyRow(),
                     const SizedBox(height: 2.0),
                            _buildPhoneText(),
                     const SizedBox(height: 2.0),
                            _buildVerifyCodeEdit(),
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

  _checkvalue()
  async{
     _name= _nameCtrl.text.trim();
      if(_name.isEmpty ){
        await DialogUtils.showToastDialog(context,'姓名输入错误');
        return false;
      }


     _phoneNo= _phoneNoCtrl.text.trim();
     if(_phoneNo.isEmpty ||  !ComFunUtil.isChinaPhoneLegal(_phoneNo) ){
       await DialogUtils.showToastDialog(context,'预留手机号必须填写');
       return false;
     }

     _idCard= _idCardCtrl.text.trim();
    if(_idCard.isEmpty ||_idCard.length<16 || _idCard.trim().length > 18){
      await DialogUtils.showToastDialog(context,'身份证号码输入错误');
      return false;
    }

    _cardNo= _cardNoCtrl.text.trim();
    if(_cardNo.isEmpty || _cardNo.length<10){
      await DialogUtils.showToastDialog(context,'卡号输入错误');
      return false;
    }


    if(_bankIdCtrl.text.isEmpty){
      await DialogUtils.showToastDialog(context,'请选择卡片银行');
      return false;
    }

    if(_regionCtrl.text.isEmpty ){
      await DialogUtils.showToastDialog(context,'请选择所属地区');
      return false;
    }

     _cardExpired= _cardExpiredCtrl.text;
    if(_cardExpired.isEmpty  && _cardType=='2'){
      await DialogUtils.showToastDialog(context,'请选择卡片有效期');
      return false;
    }

    _bankBill=_bankBillCtrl.text;
    if(_bankBill.isEmpty  && _cardType=='2'){
      await DialogUtils.showToastDialog(context,'请选择账单日');
      return false;
    }

    _bankRepayDate=_bankRepayDateCtrl.text;
    if(_bankRepayDate.isEmpty && _cardType=='2' )
      await DialogUtils.showToastDialog(context,'请选择还款日');

     _cardCvn2= _cardCvn2Ctrl.text;
     if(_cardCvn2.isEmpty && _cardType=='2' ){
       await DialogUtils.showToastDialog(context,'卡片背面3位校验码必须填写');
       return false;
     }

     final form = _formKey.currentState;
     if(form.validate())
       {
         form.save();
       }

       return true;
  }

  void _getsmsCode() async {
    print("----_getsmsCode0---");
    _cardType = widget.cardType;
    if (_checkvalue()==true) {
      _getsmscode=true;
      Map<String, String> params = {
        "cardType": _cardType,
        "name": _name,
        "idCard": _idCard,
        "cardNo": _cardNo,
        "bankId": _bankId,
        "regionCode": _regionCode,
        "branch": _region,
        "phoneNo": _phoneNo,
        "cardCvn2": _cardCvn2,
        "cardExpired": _cardExpired,
        "bankBill": _bankBill,
        "bankRepayDate": _bankRepayDate
      };

      print("----_getsmsCode1---");
      print(params);
      try {
        showLoadingDialog();
        await HttpUtils.apipost(context, "Index/cardAddFirst", params, (response) async{
          print(response);
          if (response['error_code'] == '1') {
            _orderNo = response['data']['orderNo'];
            _smsSeq = response['data']['smsSeq'];
            setState(() {
              _startTimer();
            });
          }
          await DialogUtils.showToastDialog(context, response['message']);

        });
        hideLoadingDialog();
      } catch (e) {
        print(e);
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx and is also not 304.
       await DialogUtils.showToastDialog(context, '网络连接错误');
      }
    }
    else
      _getsmscode=false;

  }

  _startTimer() {
    _seconds = 60;
    _timer = new Timer.periodic(new Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        _cancelTimer();
        return;
      }

      _seconds--;
      _verifyStr = '$_seconds(s)';
      setState(() {});
      if (_seconds == 0) {
        _verifyStr = '重新发送';
      }
    });
  }

  _cancelTimer() {
    _timer?.cancel();
  }

  @override
  void initState() {
    _initBanklist();
    // TODO: implement initState
     _name=widget.userName;
     _idCard=widget.UserIdNo;
    _nameCtrl.text=_name;
    _idCardCtrl.text=_idCard;
    super.initState();
  }

  void _initBanklist() async {
    await HttpUtils.apipost(
        context, "Index/cardSelect", {'cardType': widget.cardType}, (response) async{
      print(response);
      if (response['error_code'] == '1') {
        response['data']['bankList'].forEach((ele) {
          if (ele.isNotEmpty) {
            print(ele);
            _bankPickerData.add(ele['bankName']);
            _bankCodeMap[ele['bankName']] = ele['bankId'];
          }
        });
      } else
       await DialogUtils.showToastDialog(context, response['message']);
    });
  }

  void _forSubmitted() async{
    _cardType = widget.cardType;
    if( _smsSeq.isEmpty ||  _orderNo.isEmpty){
      await DialogUtils.showToastDialog(context,  "请先获取验证码");
      return;
    }

    _verifyCode=_verifyCodeCtrl.text.trim();
    if (_checkvalue()==true && _verifyCode != '') {
      Map<String, String> params = {
        "cardType": _cardType,
        "name": _name,
        "idCard": _idCard,
        "cardNo": _cardNo,
        "bankId": _bankId,
        "regionCode": _regionCode,
        "branch": _region,
        "phoneNo": _phoneNo,
        "cardCvn2": _cardCvn2,
        "cardExpired": _cardExpired,
        "bankBill": _bankBill,
        "bankRepayDate": _bankRepayDate,
        "orderNo": _orderNo,
        "smsSeq": _smsSeq,
        "phoneCode": _verifyCode
      };
      try {
        showLoadingDialog();

       await HttpUtils.apipost(context, "Index/cardAdd", params, (response) async{
          hideLoadingDialog();
         await DialogUtils.showToastDialog(context, response['message']);
          print(response);
          if (response['error_code'] == '1')
            Navigator.of(context).pop("1");
//            Navigator.pop(context, "1");
//        关闭当前页面并返回添加成功通知
        });
      } catch (e) {
        print(e);
        // The request was made and the server responded with a status code
        // that falls out of the range of 2xx and is also not 304.
       await DialogUtils.showToastDialog(context, '网络连接错误');
      }

      hideLoadingDialog();

    }
  }

  void _showCitySelect() async {
    Result result = await CityPickers.showCityPicker(
      context: context,
    );
    print(result);
    setState(() {
      _regionCode = result.cityId;
      _region = result.cityName;
      _regionCtrl.text = _region;
    });
  }

  Widget _buildNameText() {
    return ComFunUtil().buideStandInput(context, '姓名', _nameCtrl,enable:_name.isNotEmpty?false:true, valfun: (value){
      if (value.isEmpty) { return ''; }},svefun:(value) {
      _name = value.trim();
    } );

  }

  Widget _buildIdcardText() {
    return ComFunUtil().buideStandInput(context, '身份证号',_idCardCtrl,iType: 'number',maxlen: 18,enable:_idCard.isNotEmpty?false:true, valfun: (value){
      if (value.isEmpty ||
          value.trim().length < 16 ||
          value.trim().length > 18) {
        return '';
      }},
        svefun:(value) {
      _idCard = value.trim();
    } );

  }

  Widget _buildCardNoText() {

    return ComFunUtil().buideStandInput(context,'银行卡号',_cardNoCtrl,iType: 'number',valfun: (value){
      if (value.isEmpty || value.trim().length <= 10) {
        return '';
      }},svefun:(value) {
      _cardNo = value.trim();
    } );

  }

  Widget _buildBankIdText() {
    return InkWell(
      onTap: () {
        showBankPicker(context);
      },
      child: ComFunUtil().buideStandInput(context, '开户行', _bankIdCtrl,valfun:(value){
        if (value.isEmpty) { return ''; }},tapfun: true ),
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

  Widget _buildBranchText() {
    return ComFunUtil().buideStandInput(context, '开户地区', _branchCtrl,
        valfun:(value){
          if (value.isEmpty) { return ''; }},
        svefun: (value){
          _branch = value.trim();
        },
      );

  }

  Widget _buildCardCvn2Text() {
    return ComFunUtil().buideStandInput(context, '背面签名3位数',_cardCvn2Ctrl,maxlen:3 ,iType: 'number',
        valfun:(value){
          if (value.isEmpty) { return ''; }},
        svefun: (value){
          _cardCvn2 = value.trim();
        },
       );
  }

  Widget _buildCardExpiredText() {
    return InkWell(
      onTap: () {
        showPickermmyy(context, _cardExpiredCtrl);
      },
      child: ComFunUtil().buideStandInput(context, '卡片有效期', _cardExpiredCtrl ,
        valfun:(value){
          if (value.isEmpty) { return ''; }},
        svefun: (value){
          _cardExpired = value.trim();
        },tapfun: true
      ),
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

  Widget _buidExdymmyyRow()
  {

    return  new Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
      child: new Row(
//        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex:5,
            child:_buildCardCvn2Text(),
          ),
          Expanded(
            flex:1,
            child: new SizedBox(
              width: 10.0,
            ),
          ),
          Expanded(
            flex:5,
            child: _buildCardExpiredText(),
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
            if (value.isEmpty) { return ''; }},
          svefun: (value){
            _bankBill = value.trim();
          },tapfun: true ),
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
    svefun: (value) {
      _bankRepayDate = value.trim();
    } ,tapfun: true ),
    );

      }

  Widget _buildPhoneText() {
    return ComFunUtil().buideStandInput(context, '预留手机',_phoneNoCtrl,iType: 'number',maxlen: 11,
        valfun:(value){
          if (value.isEmpty || !ComFunUtil.isChinaPhoneLegal(value)) {
            return '';
          }},
        svefun: (value){
          _phoneNo = value.trim();
        },
      );
  }

  Widget _buildVerifyCodeEdit() {

    Widget verifyCodeEdit =
     ComFunUtil().buideStandInput(context, '短信验证码',_verifyCodeCtrl,iType: 'number',maxlen: 6,
       enable: _getsmscode,
       txtalign: TextAlign.start,txtdrt: TextDirection.ltr,
      valfun:(value){
        if (value.isEmpty() ) {
          return '';
        }},
      svefun: (value){
        _verifyCode = value.trim();
      },
    );

    Widget verifyCodeBtn = new InkWell(
      onTap: (_seconds == 0) ? _getsmsCode : null,
      child: new Container(
        alignment: Alignment.center,
        width: 70.0,
        height: 30.0,
        decoration: new BoxDecoration(
          border: new Border.all(
            width: 1.0,
            color: Colors.grey,
          ),
        ),
        child: new Text(
          '$_verifyStr',
          style: new TextStyle(fontSize: 10),
        ),
      ),
    );

    return new Padding(
      padding: const EdgeInsets.all(2),
      child: new Stack(
        children: <Widget>[
          verifyCodeEdit,
          new Align(
            alignment: Alignment.bottomRight,
            child: verifyCodeBtn,
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return FlatButton(
      color: GlobalConfig.mainColor,
//            child: Padding(
//              padding: EdgeInsets.all(5),
      child: Text(
        '添加',
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

  showBankPicker(BuildContext context) {
    new Picker(
        adapter: PickerDataAdapter<String>(pickerdata: _bankPickerData),
        hideHeader: true,
        title: new Text("银行列表"),
        cancelText: '取消',
        confirmText: '确定',
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print(picker.getSelectedValues());
          _bankName = picker.getSelectedValues()[0].toString();
          _bankIdCtrl.text = _bankName;
          _bankId = _bankCodeMap[_bankName];
          print("bankId:$_bankId");

          setState(() {});
        }).showDialog(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(addCard oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}
