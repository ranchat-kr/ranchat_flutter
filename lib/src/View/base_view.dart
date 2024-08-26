import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ranchat_flutter/src/View/base_view_model.dart';
import 'package:ranchat_flutter/theme/component/circular_indicator.dart';

class BaseView<T extends BaseViewModel> extends StatelessWidget {
  const BaseView({
    super.key,
    required this.viewModel,
    required this.builder,
  });

  final T viewModel;
  final Widget Function(BuildContext context, T viewModel) builder;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => viewModel,
      child: Consumer<T>(
        builder: (context, viewModel, child) {
          return CircularIndicator(
            isLoading: viewModel.isLoading,
            child: builder(context, viewModel),
          );
        },
      ),
    );
  }
}
