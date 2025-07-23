import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxdul/provider/MemoManager.dart';

class MemoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MemoManager>(
      builder: (context, memoManager, child) {
        final memos = memoManager.memos;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Memos',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: memos.length > 4 ? 4 : memos.length,
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
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Full Memo'),
                                    content: Text(memos[index]),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ],
        );
      },
    );
  }
}
