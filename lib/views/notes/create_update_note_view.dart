import 'package:flutter/material.dart';
// lib imports
import 'package:notevault/services/auth/auth_service.dart';
import 'package:notevault/services/cloud/cloud_note.dart';
import 'package:notevault/services/cloud/firebase_cloud_storage.dart';
import 'package:notevault/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:notevault/utilities/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textEditingController;
  late final TextEditingController _titleEditingController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textEditingController = TextEditingController();
    _titleEditingController = TextEditingController();

    super.initState();
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textEditingController.text = widgetNote.text;
      _titleEditingController.text = widgetNote.title;
      return widgetNote;
    }

    final existingNote = _note;

    if (existingNote != null) return existingNote;

    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;

    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textEditingController.text.isEmpty &&
        _titleEditingController.text.isEmpty &&
        note != null) {
      _notesService.deleteNote(docId: note.documentId);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textEditingController.text;
    final title = _titleEditingController.text;
    if (text.isNotEmpty && title.isNotEmpty && note != null) {
      await _notesService.updateNote(
          docId: note.documentId, title: title, text: text);
    }
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textEditingController.text;
    final title = _titleEditingController.text;
    await _notesService.updateNote(
        docId: note.documentId, title: title, text: text);
  }

  void _setupTextControllerListener() {
    _textEditingController.removeListener(_textControllerListener);
    _textEditingController.addListener(_textControllerListener);
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textEditingController.dispose();
    _titleEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New note for the vault!"),
        actions: [
          IconButton(
            onPressed: () async {
              final title = _titleEditingController.text;
              final text = _textEditingController.text;
              if (_note == null || text.isEmpty || title.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                Share.share("$title: $text");
              }
            },
            icon: const Icon(Icons.share),
          )
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return Column(
                children: [
                  TextField(
                    controller: _titleEditingController,
                    decoration: const InputDecoration(hintText: "Title"),
                  ),
                  TextField(
                    controller: _textEditingController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: "Type your note here..."),
                  )
                ],
              );
            default:
              return const CircularProgressIndicator.adaptive();
          }
        },
      ),
    );
  }
}
