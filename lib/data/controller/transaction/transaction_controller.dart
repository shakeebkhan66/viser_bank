import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viser_bank/core/utils/my_color.dart';
import 'package:viser_bank/core/utils/my_strings.dart';
import 'package:viser_bank/data/model/global/response_model/response_model.dart';
import 'package:viser_bank/data/model/transaction/transaction_response_model.dart';
import 'package:viser_bank/data/repo/account/transaction_log_repo.dart';
import 'package:viser_bank/views/components/snackbar/show_custom_snackbar.dart';

class TransactionController extends GetxController{

  TransactionRepo transactionRepo;
  TransactionController({required this.transactionRepo});

  bool isLoading = true;

  final formKey = GlobalKey<FormState>();

  List<String> transactionTypeList = ["All", "Plus", "Minus"];

  List<TransactionData> transactionList = [];
  List<Remarks> remarksList = [(Remarks(remark: "All",)),];
  List<Remarks> plusRemarksList = [(Remarks(remark: "All",)),];
  List<Remarks> minusRemarksList = [(Remarks(remark: "All",)),];

  String trxSearchText = '';
  String? nextPageUrl;
  int page = 0;
  int index = 0;
  String currency = '';

  TextEditingController trxController = TextEditingController();

  String selectedRemark = "All";
  String selectedTrxType = "All";

  void initialSelectedValue() async{
    page = 0;
    selectedRemark = "All";
    selectedTrxType = "All";
    trxController.text = '';
    trxSearchText = '';
    transactionList.clear();
    isLoading = true;
    update();

    await loadTransaction();
    isLoading = false;
    update();
  }


  Future<void> loadTransaction() async{

    page = page + 1;

    if(page == 1){
      currency = transactionRepo.apiClient.getCurrencyOrUsername();
      remarksList.clear();
      plusRemarksList.clear();
      minusRemarksList.clear();
      remarksList.insert(0, Remarks(remark: "All"));
      // plusRemarksList.insert(0, Remarks(remark: "All"));
      // minusRemarksList.insert(0, Remarks(remark: "All"));
      transactionList.clear();
    }

    ResponseModel responseModel = await transactionRepo.getTransactionList(
        page,
        type: selectedTrxType.toLowerCase(),
        remark: selectedRemark.toLowerCase(),
        searchText: trxSearchText
    );

    if(responseModel.statusCode == 200){
      TransactionResponseModel model = TransactionResponseModel.fromJson(jsonDecode(responseModel.responseJson));

      nextPageUrl = model.data?.transactions?.nextPageUrl;

      if(model.status.toString().toLowerCase() == "success"){
        List<TransactionData>? tempDataList = model.data?.transactions?.data;
        if(page == 1){
          List<Remarks>? tempRemarksList = model.data?.remarks;
          List<Remarks>? tempPlusRemarksList = model.data?.plusRemarks;
          List<Remarks>? tempMinusRemarksList = model.data?.minusRemarks;

          if (tempRemarksList != null && tempRemarksList.isNotEmpty) {
            for (var element in tempRemarksList) {
              if(element.remark != null && element.remark?.toLowerCase() != 'null' && element.remark!.isNotEmpty){
                remarksList.add(element);
              }
            }
          }
          if (tempPlusRemarksList != null && tempPlusRemarksList.isNotEmpty) {
            for (var element in tempPlusRemarksList) {
              if(element.remark != null && element.remark?.toLowerCase() != 'null' && element.remark!.isNotEmpty){
                plusRemarksList.add(element);
              }
            }
          }
          if (tempMinusRemarksList != null && tempMinusRemarksList.isNotEmpty) {
            for (var element in tempMinusRemarksList) {
              if(element.remark != null && element.remark?.toLowerCase() != 'null' && element.remark!.isNotEmpty){
                minusRemarksList.add(element);
              }
            }
          }
        }
        if(tempDataList != null && tempDataList.isNotEmpty){
          transactionList.addAll(tempDataList);
        }
      }
      else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong],);
      }
    }
    else {
      CustomSnackBar.error(errorList: [responseModel.message],);
    }
    update();
  }

  void changeSelectedRemark(String remarks){
    selectedRemark = remarks;
    update();
  }

  void changeSelectedTrxType(String trxType){
    selectedTrxType = trxType;
    update();
  }

  bool filterLoading = false;

  Future<void> filterData()async{
    trxSearchText = trxController.text;
    page=0;
    filterLoading=true;
    update();
    transactionList.clear();

    await loadTransaction();

    filterLoading=false;
    update();
  }

  bool hasNext(){
    return nextPageUrl !=null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null'? true:false;
  }

  bool isSearch = true;
  void changeSearchIcon(){
    isSearch = !isSearch;
    update();
    if(!isSearch){
      initialSelectedValue();
    }
  }

  Color changeTextColor(String trxType){
    return trxType == "+" ? MyColor.green : MyColor.colorRed;
  }

  int expandIndex = -1;
  void changeExpandIndex(int index){
    expandIndex = expandIndex==index?-1:index;
    update();
  }

}