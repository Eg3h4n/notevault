import 'package:flutter/material.dart';
// lib imports
import 'package:notevault/constants/routes.dart';
import 'package:notevault/enums/menu_action.dart';
import 'package:notevault/services/auth/auth_service.dart';
import 'package:notevault/services/cloud/cloud_note.dart';
import 'package:notevault/services/cloud/firebase_cloud_storage.dart';
import 'package:notevault/utilities/dialogs/logout_dialog.dart';
import 'package:notevault/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;

  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Note Vault"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              // Due to flutter's "Do not use buildcontexts across async gaps" warning we assign the navigator before awaiting
              final navigator = Navigator.of(context);
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);

                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    navigator.pushNamedAndRemoveUntil(
                        loginRoute, (route) => false);
                  }
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                    value: MenuAction.logout, child: Text("Log Out"))
              ];
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: ((context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                    onTap: (note) {
                      Navigator.of(context)
                          .pushNamed(createOrUpdateNoteRoute, arguments: note);
                    },
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(docId: note.documentId);
                    });
              } else {
                return const CircularProgressIndicator.adaptive();
              }
            default:
              return const CircularProgressIndicator.adaptive();
          }
        }),
      ),
    );
  }
}
