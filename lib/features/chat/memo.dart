import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxdul/provider/MemoManager.dart';

class MemoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MemoManager>(
      builder: (context, memoManager, child) {
        final memos = memoManager.memos;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Memos',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      decorationStyle: TextDecorationStyle.dashed,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/memo'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.pinkAccent,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text('All Memos >', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
              memos.isEmpty
                  ? Center(
                      child: Text(
                        'No memos',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: memos.length > 3 ? 3 : memos.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Material(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              title: Text(
                                memos[index],
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) => Container(
                                    padding: const EdgeInsets.all(16),
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.7,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Memo",
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Container(
                                              width: 600,
                                              padding: const EdgeInsets.all(16),
                                              child: Text(
                                                memos[index],
                                                textAlign: TextAlign.justify,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }
}
