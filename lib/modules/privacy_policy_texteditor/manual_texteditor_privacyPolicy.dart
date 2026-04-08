// // import 'package:flutter/material.dart';
// // import 'package:locate_your_dentist/common_widgets/color_code.dart';
// // import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
// // import 'package:flutter_quill/flutter_quill.dart' as quill;
// // import 'package:rich_editor/rich_editor.dart';
// // import 'package:flutter_quill/flutter_quill.dart' hide Text;
// //
// // class PrivacyPolicy extends StatefulWidget {
// //   const PrivacyPolicy({super.key});
// //
// //   @override
// //   State<PrivacyPolicy> createState() => _PrivacyPolicyState();
// // }
// //
// // class _PrivacyPolicyState extends State<PrivacyPolicy> {
// //   //final quill.QuillController _controller = quill.QuillController.basic();
// //   final ScrollController _scrollController = ScrollController();
// //   final FocusNode _focusNode = FocusNode();
// //   final quill.QuillController _controller = quill.QuillController.basic();
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         centerTitle: true,
// //         automaticallyImplyLeading: true,
// //         iconTheme: const IconThemeData(color: AppColors.white),
// //         title: Text(
// //           'Privacy Policy',
// //           style: AppTextStyles.headline(context, color: AppColors.white),
// //         ),
// //         backgroundColor: AppColors.primary,
// //       ),
// //       body: Column(
// //         children: [
// //           // quill.QuillToolbar.basic(controller: _controller),
// //           // Expanded(
// //           //   child: quill.QuillEditor(
// //           //     controller: _controller,
// //           //     scrollController: _scrollController,
// //           //     scrollable: true,
// //           //     focusNode: _focusNode,
// //           //     autoFocus: false,
// //           //     readOnly: false,
// //           //     expands: true,
// //           //     padding: const EdgeInsets.all(16),
// //           //   ),
// //           // ),
// //         quill.QuillEditor(
// //         controller: _controller,
// //         focusNode: _focusNode,
// //         scrollController: ScrollController(),
// //         scrollable: true,
// //         padding: EdgeInsets.all(10),
// //         readOnly: false,
// //         expands: false,
// //         autoFocus: true,
// //        // embedBuilders: defaultEmbedBuildersWeb,
// //        // customStyles: DefaultStyles.getInstance(),
// //       ),
// //
// //       QuillToolbar.basic(
// //       controller: _controller,
// //       showAlignmentButtons: true,
// //       multiRowsDisplay: false,
// //     )
// //
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:zefyrka/zefyrka.dart';
//
// class ZefyrExample extends StatefulWidget {
//   const ZefyrExample({super.key});
//
//   @override
//   State<ZefyrExample> createState() => _ZefyrExampleState();
// }
//
// class _ZefyrExampleState extends State<ZefyrExample> {
//   late ZefyrController _controller;
//   final FocusNode _focusNode = FocusNode();
//
//   @override
//   void initState() {
//     super.initState();
//     // You can load initial text here
//     final document = NotusDocument(); // empty document
//     _controller = ZefyrController(document);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Zefyr Editor'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: () {
//               // Get plain text
//               final plainText = _controller.document.toPlainText();
//               print("Saved content: $plainText");
//
//               // Or save as JSON
//               final json = _controller.document.toJson();
//               print("Document JSON: $json");
//             },
//           )
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ZefyrEditor(
//           controller: _controller,
//           focusNode: _focusNode,
//           padding: const EdgeInsets.all(8),
//           autofocus: true,
//         ),
//       ),
//     );
//   }
// }