import 'package:exemplo_banco/models/user_model.dart';
import 'package:exemplo_banco/repositories/user_repository.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final UserRepository _repository = UserRepositoryImp();
  int? selectId;
  final _formKey = GlobalKey<FormState>();

  Widget _rowField({
    required TextEditingController controller,
    required TextInputType keyboard,
    required String? text,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        textInputAction: TextInputAction.newline,
        showCursor: true,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none),
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none),
          labelText: text,
          filled: true,
          isDense: true,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'O campo não pode estar vazio';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários'),
        elevation: 4.0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              selectId = null;
              _resetFields();
              _openDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<UserModel>>(
          future: _repository.fetchAll(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Text('Carregando...'),
              );
            }
            return snapshot.data!.isEmpty
                ? const Center(child: Text('Não há usuários cadastrados'),)
                : SizedBox(
                    height: snapshot.data!.length * 300,
                    width: double.infinity,
                    child: ListView.builder(
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return Center(
                          child: ListTile(
                            title: Text(snapshot.data![index].name!),
                            subtitle: Text(snapshot.data![index].email!),
                            trailing: CircleAvatar(
                                backgroundColor: Colors.black38,
                                child:
                                    Text(snapshot.data![index].age.toString())),
                            onLongPress: () async {
                              _removeUserById(context,
                                  userRepository: _repository,
                                  id: snapshot.data![index].id);
                            },
                            onTap: () {
                              UserModel userModel = UserModel(
                                  id: selectId = snapshot.data![index].id,
                                  name: _nameController.text =
                                  snapshot.data![index].name!,
                                  email: _emailController.text =
                                  snapshot.data![index].email!,
                                  age: int.parse(_ageController.text =
                                      snapshot.data![index].age.toString()));
                              _openDialog(context, user: userModel);
                            },
                          ),
                        );
                      },
                    ),
                  );
          },
        ),
      ),
    );
  }

  void _openDialog(BuildContext context, {UserModel? user}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(selectId != null ? 'Atualizar Cadastro' : 'Cadastrar Usuário'),
        content: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: SizedBox(
            height: 300,
            width: 400,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _rowField(
                    controller: _nameController,
                    keyboard: TextInputType.name,
                    text: 'Digite o Nome',
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  _rowField(
                      controller: _emailController,
                      keyboard: TextInputType.emailAddress,
                      text: 'Digite o E-mal',
                      icon: Icons.email_rounded),
                  const SizedBox(
                    height: 12.0,
                  ),
                  _rowField(
                    controller: _ageController,
                    keyboard: TextInputType.number,
                    text: 'Informe a Idade',
                    icon: Icons.numbers_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _registerUser();
                  _resetFields();
                  Navigator.of(context).pop();
                  setState(() {});
                }
              },
              child: Text(
                selectId != null ? 'Atualizar' : 'Salvar',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ))
        ],
      ),
    );
  }

  Future<void> _registerUser() async {
    selectId != null
        ? await _repository.update(UserModel(
            id: selectId,
            name: _nameController.text,
            email: _emailController.text,
            age: int.parse(_ageController.text)))
        : await _repository.save(UserModel(
            name: _nameController.text,
            email: _emailController.text,
            age: int.parse(_ageController.text)));
  }

  _resetFields() {
    _nameController.clear();
    _emailController.clear();
    _ageController.clear();
  }

  _removeUserById(BuildContext context,
      {required UserRepository userRepository, int? id}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Deletar Usuário'),
              content: const Text('Você deseja remover esse usuário?'),
              elevation: 2.0,
              actions: [
                TextButton(
                  child: const Text('Sim'),
                  onPressed: () async {
                    userRepository.delete(id!);
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                ),
                TextButton(
                  child: const Text('Não'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ));
  }
}
