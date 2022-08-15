import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// lib imports
import 'package:notevault/constants/routes.dart';
import 'package:notevault/enums/menu_action.dart';
import 'package:notevault/services/auth/auth_service.dart';
import 'package:notevault/services/auth/bloc/auth_bloc.dart';
import 'package:notevault/services/auth/bloc/auth_event.dart';
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
              // Due to flutter's "Do not use buildcontexts across async gaps" warning we assign the authbloc before awaiting
              final authBloc = context.read<AuthBloc>();
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);

                  if (shouldLogout) {
                    authBloc.add(const AuthEventLogOut());
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
