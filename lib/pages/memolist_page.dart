import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxdul/provider/memo_manager.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MemoListPage extends StatefulWidget {
  const MemoListPage({super.key});
  @override
  _MemoListPageState createState() => _MemoListPageState();
}

class _MemoListPageState extends State<MemoListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'My Memos',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: <Color>[Colors.purpleAccent, Colors.deepPurple],
              ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Consumer<MemoManager>(
                builder: (context, memoManager, child) {
                  final memos = memoManager.memos;

                  if (memos.isEmpty) {
                    return Center(child: Text('No memos yet.'));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.zero,

                    itemCount: memos.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),

                        child: Slidable(
                          key: ValueKey(memos[index]),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  memoManager.removeMemo(memos[index]);
                                },
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,

                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.grey.shade100],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withAlpha(
                                    (0.2 * 255).round(),
                                  ),
                                  blurRadius: 6,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
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
                                              width: double.infinity,
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
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
