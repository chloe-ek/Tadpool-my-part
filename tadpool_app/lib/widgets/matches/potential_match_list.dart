import 'package:flutter/material.dart';
import 'package:tadpool_app/constants/style_constants.dart' as kStyle;
import 'package:tadpool_app/services/matching_service.dart';
import 'package:tadpool_app/utils/numbers_utils.dart';
import 'package:tadpool_app/widgets/matches/potential_match_profile_screen.dart';

class PotentialMatchList extends StatefulWidget {
  const PotentialMatchList({Key? key}) : super(key: key);

  @override
  _PotentialMatchList createState() => _PotentialMatchList();
}

class _PotentialMatchList extends State<PotentialMatchList> {
  final Future<List<dynamic>?> _matchingList =
      MatchingService.getMatchingList();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>?>(
      future: _matchingList,
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Something went wrong: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No matches found."));
        }

        final children = snapshot.data!.map((dynamic data) {
          final user = data['user'] ?? {};
          final String name = user['name'] ?? 'Unnamed User';
          final int id = data['id'] ?? 0;
          final String imageUrl = user['face_picture_URL'] ?? '';
          final String average =
              ((data['average'] ?? 0.0) * 100).round().toString();
          final String distance =
              NumbersUtils.roundDouble(data['distance'] ?? 0.0, 2).toString();

          return PotentialMatchListItem(
            name: name,
            matchPercentage: average,
            distance: distance,
            image: imageUrl,
            id: id,
            data: data,
          );
        }).toList();

        return ListView(children: children);
      },
    );
  }
}

class PotentialMatchListItem extends StatelessWidget {
  const PotentialMatchListItem({
    Key? key,
    required this.data,
    required this.name,
    required this.matchPercentage,
    required this.distance,
    required this.image,
    required this.id,
  }) : super(key: key);

  final dynamic data;
  final String image;
  final String name;
  final String matchPercentage;
  final String distance;
  final int id;

  @override
  Widget build(BuildContext context) {
    final String displayImage = (image.trim().isNotEmpty)
        ? (image.startsWith('http') ? image : 'https://$image')
        : "https://cdn.mos.cms.futurecdn.net/FWV8wxH4HU6HXwZmGhjCqn.jpg";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              displayImage,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  "https://cdn.mos.cms.futurecdn.net/FWV8wxH4HU6HXwZmGhjCqn.jpg",
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name, style: kStyle.listTitle),
                  if (data['is_verified'] == true)
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(Icons.verified, color: Colors.blueAccent, size: 20.0),
                    ),
                ],
              ),
              Text('$matchPercentage% match', style: kStyle.listSubtitle1),
              Text('$distance km', style: kStyle.listSubtitle2),
            ],
        ),

          NextButton(data: data),
        ],
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  const NextButton({Key? key, required this.data}) : super(key: key);
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
      elevation: 5.0,
      color: kStyle.primaryGreen,
      clipBehavior: Clip.antiAlias,
      child: MaterialButton(
        minWidth: 10,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  PotentialMatchProfile(data: data),
            ),
          );
        },
        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20.0),
      ),
    );
  }
}
