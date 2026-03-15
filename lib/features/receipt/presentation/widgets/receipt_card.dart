import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/receipt_model.dart';

class ReceiptCard extends StatelessWidget {
  final ReceiptModel receipt;
  final String title;
  final void Function(int) onDelete;

  const ReceiptCard({
    super.key,
    required this.receipt,
    required this.title,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        isThreeLine: true,
        dense: true,
        leading:
            receipt.imagePath != null && File(receipt.imagePath!).existsSync()
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(receipt.imagePath!),
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.receipt_long),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total: ${receipt.total.toStringAsFixed(2)} THB'),
            if ((receipt.vat ?? 0) > 0)
              Text('VAT: ${(receipt.vat ?? 0).toStringAsFixed(2)} THB'),
            Text('Category: ${receipt.category}'),
            Text('Date: ${receipt.date.isEmpty ? 'Unknown' : receipt.date}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: receipt.id != null ? () => onDelete(receipt.id!) : null,
          tooltip: 'ลบรายการนี้',
        ),
      ),
    );
  }
}
