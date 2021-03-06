import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/providers/country_provider.dart';
import 'package:intl_phone_number_input/src/utils/formatter/as_you_type_formatter.dart';
import 'package:intl_phone_number_input/src/utils/phone_number.dart';
import 'package:intl_phone_number_input/src/utils/test/test_helper.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';
import 'package:intl_phone_number_input/src/utils/widget_view.dart';
import 'package:intl_phone_number_input/src/widgets/selector_button.dart';
import 'package:libphonenumber/libphonenumber.dart';

enum PhoneInputSelectorType { DROPDOWN, BOTTOM_SHEET, DIALOG }

typedef InputChanged<T> = void Function(T value);

class InternationalPhoneNumberInput extends StatefulWidget {
  final PhoneInputSelectorType selectorType;

  final InputChanged<PhoneNumber> onInputChanged;
  final InputChanged<bool> onInputValidated;

  final VoidCallback onSubmit;
  final TextEditingController textFieldController;
  final TextInputAction keyboardAction;

  final PhoneNumber initialValue;
  final String hintText;
  final String errorMessage;

  final bool isEnabled;
  final bool formatInput;
  final bool autoFocus;
  final bool autoValidate;
  final bool ignoreBlank;
  final bool countrySelectorScrollControlled;

  final String locale;

  final TextStyle textStyle;
  final TextStyle selectorTextStyle;
  final InputBorder inputBorder;
  final InputDecoration inputDecoration;
  final InputDecoration searchBoxDecoration;

  final FocusNode focusNode;

  final List<String> countries;

  InternationalPhoneNumberInput(
      {Key key,
      this.selectorType = PhoneInputSelectorType.DROPDOWN,
      this.onInputChanged,
      this.onInputValidated,
      this.onSubmit,
      this.textFieldController,
      this.keyboardAction,
      this.initialValue,
      this.hintText = 'Phone number',
      this.errorMessage = 'Invalid phone number',
      this.isEnabled = true,
      this.formatInput = true,
      this.autoFocus = false,
      this.autoValidate = false,
      this.ignoreBlank = false,
      this.countrySelectorScrollControlled = true,
      this.locale,
      this.textStyle,
      this.selectorTextStyle,
      this.inputBorder,
      this.inputDecoration,
      this.searchBoxDecoration,
      this.focusNode,
      this.countries})
      : super(key: key);

  factory InternationalPhoneNumberInput.withCustomDecoration({
    Key key,
    PhoneInputSelectorType selectorType,
    @required InputChanged<PhoneNumber> onInputChanged,
    InputChanged<bool> onInputValidated,
    FocusNode focusNode,
    TextEditingController textFieldController,
    VoidCallback onSubmit,
    TextInputAction keyboardAction,
    List<String> countries,
    TextStyle textStyle,
    TextStyle selectorTextStyle,
    String errorMessage,
    @required InputDecoration inputDecoration,
    InputDecoration searchBoxDecoration,
    PhoneNumber initialValue,
    bool isEnabled,
    bool formatInput,
    bool autoFocus,
    bool autoValidate,
    bool ignoreBlank,
    bool countrySelectorScrollControlled,
    String locale,
  }) {
    return InternationalPhoneNumberInput(
      key: key,
      selectorType: selectorType ?? PhoneInputSelectorType.DROPDOWN,
      onInputChanged: onInputChanged,
      onInputValidated: onInputValidated,
      focusNode: focusNode,
      textFieldController: textFieldController,
      onSubmit: onSubmit,
      keyboardAction: keyboardAction,
      countries: countries,
      textStyle: textStyle,
      selectorTextStyle: selectorTextStyle,
      inputDecoration: inputDecoration,
      searchBoxDecoration: searchBoxDecoration,
      initialValue: initialValue,
      isEnabled: isEnabled ?? true,
      formatInput: formatInput ?? true,
      autoFocus: autoFocus ?? false,
      autoValidate: autoValidate ?? false,
      ignoreBlank: ignoreBlank ?? false,
      errorMessage: errorMessage ?? 'Invalid phone number',
      locale: locale,
      countrySelectorScrollControlled: countrySelectorScrollControlled ?? true,
    );
  }

  factory InternationalPhoneNumberInput.withCustomBorder({
    Key key,
    PhoneInputSelectorType selectorType,
    @required InputChanged<PhoneNumber> onInputChanged,
    InputChanged<bool> onInputValidated,
    FocusNode focusNode,
    TextEditingController textFieldController,
    VoidCallback onSubmit,
    TextInputAction keyboardAction,
    List<String> countries,
    TextStyle textStyle,
    TextStyle selectorTextStyle,
    @required InputBorder inputBorder,
    String hintText,
    PhoneNumber initialValue,
    String errorMessage,
    bool isEnabled,
    bool formatInput,
    bool autoFocus,
    bool autoValidate,
    bool ignoreBlank,
    bool countrySelectorScrollControlled,
    String locale,
  }) {
    return InternationalPhoneNumberInput(
      key: key,
      selectorType: selectorType ?? PhoneInputSelectorType.DROPDOWN,
      onInputChanged: onInputChanged,
      onInputValidated: onInputValidated,
      focusNode: focusNode,
      textFieldController: textFieldController,
      onSubmit: onSubmit,
      keyboardAction: keyboardAction,
      countries: countries,
      textStyle: textStyle,
      selectorTextStyle: selectorTextStyle,
      inputBorder: inputBorder,
      hintText: hintText ?? 'Phone number',
      initialValue: initialValue,
      errorMessage: errorMessage ?? 'Invalid phone number',
      formatInput: formatInput ?? true,
      isEnabled: isEnabled ?? true,
      autoFocus: autoFocus ?? false,
      autoValidate: autoValidate ?? false,
      ignoreBlank: ignoreBlank ?? false,
      locale: locale,
      countrySelectorScrollControlled: countrySelectorScrollControlled ?? true,
    );
  }

  @override
  State<StatefulWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InternationalPhoneNumberInput> {
  TextEditingController controller;
  FocusNode focusNode;

  Country country;
  List<Country> countries = [];
  bool isNotValid = true;

  @override
  void initState() {
    Future.delayed(Duration.zero, () => loadCountries(context));
    focusNode = widget.focusNode ?? FocusNode();
    controller = widget.textFieldController ?? TextEditingController();
    initialiseWidget();
    super.initState();
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _InputWidgetView(
      state: this,
    );
  }

  @override
  void didUpdateWidget(InternationalPhoneNumberInput oldWidget) {
    if (oldWidget.initialValue != widget.initialValue) {
      loadCountries(context);
      initialiseWidget();
    }
    super.didUpdateWidget(oldWidget);
  }

  void initialiseWidget() async {
    if (widget.initialValue != null) {
      if (widget.initialValue.phoneNumber != null &&
          widget.initialValue.phoneNumber.isNotEmpty) {
        controller.text =
            await PhoneNumber.getParsableNumber(widget.initialValue);

        phoneNumberControllerListener();
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      if (widget.autoFocus && !focusNode.hasFocus) {
        FocusScope.of(context).requestFocus(focusNode);
      }
    });
  }

  void loadCountries(BuildContext context) {
    if (this.mounted) {
      List<Country> countries = CountryProvider.getCountriesData(
          context: context, countries: widget.countries);

      Country country = Utils.getInitialSelectedCountry(
        countries,
        widget.initialValue?.isoCode ?? '',
      );

      setState(() {
        this.countries = countries;
        this.country = country;
      });
    }
  }

  void phoneNumberControllerListener() {
    if (this.mounted) {
      String parsedPhoneNumberString =
          controller.text.replaceAll(RegExp(r'[^\d+]'), '');

      getParsedPhoneNumber(parsedPhoneNumberString, this.country?.countryCode)
          .then((phoneNumber) {
        if (phoneNumber == null) {
          String phoneNumber =
              '${this.country?.dialCode}$parsedPhoneNumberString';
          widget.onInputChanged(PhoneNumber(
              phoneNumber: phoneNumber,
              isoCode: this.country?.countryCode,
              dialCode: this.country?.dialCode));
          if (widget.onInputValidated != null) {
            widget.onInputValidated(false);
          }
          this.isNotValid = true;
        } else {
          widget.onInputChanged(PhoneNumber(
              phoneNumber: phoneNumber,
              isoCode: this.country?.countryCode,
              dialCode: this.country?.dialCode));
          if (widget.onInputValidated != null) {
            widget.onInputValidated(true);
          }
          this.isNotValid = false;
        }
      });
    }
  }

  Future<String> getParsedPhoneNumber(String phoneNumber, String iso) async {
    if (phoneNumber.isNotEmpty && iso != null) {
      try {
        bool isValidPhoneNumber = await PhoneNumberUtil.isValidPhoneNumber(
            phoneNumber: phoneNumber, isoCode: iso);

        if (isValidPhoneNumber) {
          return await PhoneNumberUtil.normalizePhoneNumber(
              phoneNumber: phoneNumber, isoCode: iso);
        }
      } on Exception {
        return null;
      }
    }
    return null;
  }

  InputDecoration getInputDecoration(InputDecoration decoration) {
    return decoration ??
        InputDecoration(
          border: widget.inputBorder ?? UnderlineInputBorder(),
          hintText: widget.hintText,
        );
  }

  void onChanged(String value) {
    phoneNumberControllerListener();
  }

  String validator(String value) {
    return this.isNotValid && (value.isNotEmpty || widget.ignoreBlank == false)
        ? widget.errorMessage
        : null;
  }

  void onCountryChanged(Country country) {
    setState(() {
      this.country = country;
    });

    phoneNumberControllerListener();
  }
}

class _InputWidgetView
    extends WidgetView<InternationalPhoneNumberInput, _InputWidgetState> {
  final _InputWidgetState state;

  _InputWidgetView({Key key, @required this.state})
      : super(key: key, state: state);

  @override
  Widget build(BuildContext context) {
    final countryCode = state?.country?.countryCode ?? '';
    final dialCode = state?.country?.dialCode ?? '';

    return Container(
      child: Row(
        textDirection: TextDirection.ltr,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SelectorButton(
            country: state.country,
            countries: state.countries,
            onCountryChanged: state.onCountryChanged,
            selectorType: widget.selectorType,
            selectorTextStyle: widget.selectorTextStyle,
            searchBoxDecoration: widget.searchBoxDecoration,
            locale: widget.locale,
            phoneNumberControllerListener: state.phoneNumberControllerListener,
            isEnabled: widget.isEnabled,
            isScrollControlled: widget.countrySelectorScrollControlled,
          ),
          SizedBox(width: 12),
          Flexible(
            child: TextFormField(
              key: Key(TestHelper.TextInputKeyValue),
              textDirection: TextDirection.ltr,
              controller: state.controller,
              focusNode: state.focusNode,
              enabled: widget.isEnabled,
              keyboardType: TextInputType.phone,
              textInputAction: widget.keyboardAction,
              style: widget.textStyle,
              decoration: state.getInputDecoration(widget.inputDecoration),
              onEditingComplete: widget.onSubmit,
              autovalidate: widget.autoValidate,
              validator: state.validator,
              inputFormatters: [
                LengthLimitingTextInputFormatter(15),
                widget.formatInput
                    ? AsYouTypeFormatter(
                        isoCode: countryCode,
                        dialCode: dialCode,
                        onInputFormatted: (TextEditingValue value) {
                          state.controller.value = value;
                        },
                      )
                    : WhitelistingTextInputFormatter.digitsOnly,
              ],
              onChanged: state.onChanged,
            ),
          )
        ],
      ),
    );
  }
}
