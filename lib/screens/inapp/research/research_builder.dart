import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trid_travel/blocs/research_bloc/research_bloc.dart';
import 'package:trid_travel/models/research_model/research_model.dart';
import 'package:trid_travel/utils/scroll_behaviour.dart';
import 'package:trid_travel/utils/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

BlocBuilder<ResearchBloc, ResearchState> researchBlocBuilder() {
  return BlocBuilder<ResearchBloc, ResearchState>(
    builder: ((context, state) {
      if (state is ResearchLoadingState) {
        return const ShimmerLoader();
      } else if (state is ResearchLoadedState) {
        final researchDataList = state.researchData;
        return researchBuilder(context, researchDataList);
      } else if (state is ResearchErrorState) {
        return researchWarning(context);
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.amber,
          ),
          const SizedBox(
            height: 15,
          ),
          Text('$state')
        ],
      );
    }),
  );
}

Widget researchBuilder(
    BuildContext context, List<ResearchModel> researchDataList) {
  return Center(
      child: RefreshIndicator(
    triggerMode: RefreshIndicatorTriggerMode.anywhere,
    onRefresh: () async {
      context.read<ResearchBloc>().add(ResearchRefreshEvent());
    },
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: researchDataList.length,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final ResearchModel singleData = researchDataList[index];
        return cardBuilder(singleData);
      },
    ),
  ));
}

Widget researchWarning(BuildContext context) {
  return RefreshIndicator(
    triggerMode: RefreshIndicatorTriggerMode.onEdge,
    onRefresh: () async {
      context.read<ResearchBloc>().add(ResearchRefreshEvent());
    },
    color: Colors.amber,
    child: RemoveScrollGlow(
      child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 130),
          children: [
            Container(
              alignment: Alignment.center,
              width: 200,
              height: 200,
              child: Image.asset(
                'images/error.png',
                fit: BoxFit.contain,
              ),
            ),
            const Text(
              'Oops!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 50,
                  fontWeight: FontWeight.bold),
            ),
            const Text(
              'Unable to process your request',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 16),
            )
          ]),
    ),
  );
}

Widget cardBuilder(ResearchModel singleData) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
    child: Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                //* Media - Image
                Container(
                    width: 135,
                    height: 135,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: Colors.white,
                    ),
                    child: singleData.media.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(
                              'images/error1.png',
                            ),
                          )
                        : Image.memory(base64Decode(singleData.media),
                            fit: BoxFit.contain)),
                const SizedBox(width: 10),
                //* Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        singleData.title,
                        style: GoogleFonts.lato(
                            color: const Color.fromARGB(255, 32, 32, 32),
                            fontSize: 22,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              //* Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  singleData.description,
                  textAlign: TextAlign.justify,
                  style: GoogleFonts.lato(
                    color: const Color.fromARGB(221, 23, 23, 23),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                        text: TextSpan(children: [
                      const TextSpan(
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.normal),
                          text: "To learn more "),
                      TextSpan(
                          style: const TextStyle(color: Colors.amber),
                          text: "Click here",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              Uri url = Uri.parse(singleData.link);
                              if (await canLaunchUrl(url)) {
                                launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              } else {
                                throw 'Could not launch $url';
                              }
                            }),
                    ])),
                    Text(
                      'on ${singleData.createdAt.join('/')} by ${singleData.createdBy.toUpperCase()}',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ],
          )),
    ),
  );
}
