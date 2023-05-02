import 'package:flutter/material.dart';

class FindPasswordScreen extends StatefulWidget {
  const FindPasswordScreen({super.key});

  @override
  State<FindPasswordScreen> createState() => _FindPasswordScreenState();
}

class _FindPasswordScreenState extends State<FindPasswordScreen> {
  var isClicked = false;

  TextEditingController addrTecFind = TextEditingController();

  TextEditingController nameTecFind = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        centerTitle: true,
        title: const Text('공강구조대!'),
        backgroundColor: Colors.grey,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 150,
                  ),
                  const Text('학교 이메일 주소'),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: addrTecFind,
                    decoration: const InputDecoration(
                      labelText: '주소',
                      hintText: '@uos.ac.kr',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('이름'),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: nameTecFind,
                    decoration: const InputDecoration(
                      labelText: '이름',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                          onPressed: () {
                            setState(() {
                              isClicked = true;
                            });
                          },
                          child: const Text(
                            '인증하기',
                            style: TextStyle(color: Colors.black),
                          ))
                    ],
                  ),
                  Visibility(
                    visible: isClicked,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const TextField(
                          decoration: InputDecoration(
                            labelText: '인증코드',
                            hintText: '코드를 입력하세요',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        //전송, 재전송버튼
                        OutlinedButton(
                          onPressed: () {
                            isClicked = true;
                          },
                          child: const Text(
                            '확인',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
