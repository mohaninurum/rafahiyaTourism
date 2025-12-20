import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/view/admin_side_code/view/auth/successmessage_screen.dart';

import '../../../../const/color.dart';
import '../../data/subAdminProvider/admin_otpVerification.dart';



class SubAdminVerificationCodeScreen extends StatefulWidget {
  const SubAdminVerificationCodeScreen({super.key});

  @override
  State<SubAdminVerificationCodeScreen> createState() =>
      _SubAdminVerificationCodeScreenState();
}

class _SubAdminVerificationCodeScreenState
    extends State<SubAdminVerificationCodeScreen> {
  @override
  Widget build(BuildContext context) {
    final otpProvider = Provider.of<AdminOtpVerification>(context);

    Widget otpBox(int index) {
      return SizedBox(
        width: 60,
        height: 60,
        child: TextFormField(
          controller: otpProvider.otpControllers[index],
          focusNode: otpProvider.focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
          maxLength: 1,
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.whiteColor,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.whiteColor, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.whiteColor, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.whiteColor, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onChanged: (value) => otpProvider.onOtpChanged(index, value, context),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(
                        CupertinoIcons.back,
                        color: AppColors.whiteColor,
                        size: 25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 100),
                  Text(
                    'Verification',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 70),
              Text(
                'Enter Your\nVerification Code',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.whiteColor,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) => otpBox(index)),
                ),
              ),
              SizedBox(height: 30),

              // ElevatedButton(
              //   onPressed: () {
              //     bool isValid = otpProvider.validateOtp();
              //     final snackBar = SnackBar(
              //       content: Text(
              //         isValid ? 'OTP Verified!' : 'Invalid OTP',
              //         style: TextStyle(color: Colors.white),
              //       ),
              //       backgroundColor: isValid ? Colors.green : Colors.red,
              //     );
              //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
              //
              //     if (isValid) {
              //       // Navigate or do something
              //     }
              //   },
              //   child: Text("Verify"),
              // ),
              RichText(
                  text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'We sent a four digital verification code to your email',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.whiteColor,
                          ),
                        ),
                        WidgetSpan(child: SizedBox(width: 5,)),
                        TextSpan(
                          text: 'abcd@gmail.com.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.blackBackground,
                          ),
                        ),
                        WidgetSpan(child: SizedBox(width: 5,)),
                        TextSpan(
                          text: 'You can check your inbox',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ]
                  ),
              ),

              const SizedBox(height: 30),
              Text(
                "I didn't receive the code? Send again",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                  color: AppColors.blackBackground,
                ),
              ),
              const SizedBox(height: 50),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminOtpSuccessScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 52,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: AppColors.mainColor,
                      borderRadius: BorderRadius.circular(25)
                  ),
                  child: Center(
                    child: Text(
                      'Verify',
                      style: GoogleFonts.poppins(
                        color: AppColors.whiteBackground,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
