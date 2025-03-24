import 'package:do_an_lt/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsDetailPage extends StatelessWidget {
  final Map<String, dynamic> newsItem;

  const NewsDetailPage({Key? key, required this.newsItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [blue, Colors.black],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tin tức', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold) ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                newsItem['name'] ?? 'Không có tiêu đề',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (newsItem['imageUrl'] != null && newsItem['imageUrl'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    newsItem['imageUrl'],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                newsItem['date'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            if (newsItem['detail'] != null && newsItem['detail'] is List)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildDetailContent(newsItem['detail']),
                ),
              ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Xem thêm các tin tức khác',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('news').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('Không có tin tức nào.');
                }
                final news = snapshot.data!.docs
                    .where((doc) => doc.id != newsItem['id'])
                    .toList();

                return SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: news.length,
                    itemBuilder: (context, index) {
                      final doc = news[index];
                      final title = doc['name'] ?? 'Không có tiêu đề';
                      final imageUrl = doc['imageUrl'] ?? '';
                      final date = doc['date'] ?? '';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetailPage(
                                newsItem: {
                                  'id': doc.id,
                                  'name': title,
                                  'imageUrl': imageUrl,
                                  'date': date,
                                  'detail': doc['detail'],
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 250,
                          margin: const EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                child: Image.network(
                                  imageUrl,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    height: 150,
                                    color: Colors.grey,
                                    child: const Center(child: Icon(Icons.error)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10, bottom: 10),
                                child: Text(
                                  date,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetailContent(List<dynamic> detail) {
    List<Widget> widgets = [];
    for (int i = 0; i < detail.length; i++) {
      if (i % 2 == 0) {
        // Tiêu đề
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 5.0),
            child: Text(
              detail[i],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else {
        // Nội dung
        final content = detail[i].toString().split('–');
        widgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content.map((line) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  line.trim(),
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          ),
        );
      }
    }
    return widgets;
  }
}