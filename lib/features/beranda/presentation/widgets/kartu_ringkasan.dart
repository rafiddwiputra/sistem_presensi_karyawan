import 'package:flutter/material.dart';

class KartuRingkasan extends StatelessWidget {
  const KartuRingkasan({
    super.key,
    required this.judul,
    required this.subjudul,
    required this.jumlah,
    required this.ikon,
    required this.warnaIkon,
    required this.warnaLatar,
    required this.warnaSubjudul,
    required this.onTap,
    this.ukuranFontJudul = 17,
  });

  final String judul;
  final String subjudul;
  final String jumlah;
  final IconData ikon;
  final Color warnaIkon;
  final Color warnaLatar;
  final Color warnaSubjudul;
  final VoidCallback onTap;
  final double ukuranFontJudul;

  static const Color _warnaTeks = Color(0xFF20283B);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: warnaLatar,
      borderRadius: BorderRadius.circular(21),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: warnaIkon,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  ikon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const Spacer(),
              Text(
                judul,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _warnaTeks,
                  fontSize: ukuranFontJudul,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subjudul,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: warnaSubjudul,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        jumlah,
                        style: const TextStyle(
                          color: _warnaTeks,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 25,
                    color: _warnaTeks,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
