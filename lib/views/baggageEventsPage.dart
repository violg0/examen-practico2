import 'package:flutter/material.dart';
import 'package:tiendatech/models/Baggages.dart' show Nota;
import 'package:tiendatech/models/Producto.dart' show Producto;
import 'package:tiendatech/repository/nota_repository.dart' show NotaRepository;

class ProductoDetallePage extends StatefulWidget {
  final Producto producto;
  final NotaRepository repositorio;

  ProductoDetallePage({
    super.key,
    required this.producto,
    NotaRepository? repositorio,
  }) : repositorio = repositorio ?? NotaRepository();

  @override
  State<ProductoDetallePage> createState() => _ProductoDetallePageState();
}

class _ProductoDetallePageState extends State<ProductoDetallePage> {
  static const int _prioridadMaxima = 5;
  static const int _prioridadMinimaParaGuardar = 2;
  static const int _largoMaximoNota = 500;

  final TextEditingController _textoController = TextEditingController();

  int _prioridad = 1;

  Nota? _registro;
  bool _cargandoRegistro = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarRegistro();
  }

  @override
  void dispose() {
    _textoController.dispose();
    super.dispose();
  }


  Future<void> _cargarRegistro() async {
    try {
      final registro = await widget.repositorio.obtenerPorProducto(
        widget.producto.id,
      );

      if (!mounted) return;
      setState(() {
        _registro = registro;
        if (registro != null) {
          _textoController.text = registro.texto;
          _prioridad = registro.priority;
        }
      });
    } catch (_) {
      if (mounted) _mostrarMensaje('No se pudo leer la información guardada');
    } finally {
      if (mounted) setState(() => _cargandoRegistro = false);
    }
  }

  String? _validar(String texto) {
    if (_prioridad < _prioridadMinimaParaGuardar) {
      return 'La prioridad debe ser $_prioridadMinimaParaGuardar o más '
          'para guardar';
    }
    if (texto.isEmpty) {
      return 'Escribe una nota antes de guardar';
    }
    return null;
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    FocusScope.of(context).unfocus();

    final texto = _textoController.text.trim();

    final error = _validar(texto);
    if (error != null) {
      _mostrarMensaje(error);
      return;
    }

    setState(() => _guardando = true);
    try {
      final guardada = await widget.repositorio.guardar(
        idProducto: widget.producto.id,
        texto: texto,
        priority: _prioridad,
      );

      if (!mounted) return;
      setState(() => _registro = guardada);
      _mostrarMensaje(
        guardada.pendingSync
            ? 'Guardado en el dispositivo. Pendiente de sincronizar'
            : 'Guardado y sincronizado',
      );
    } catch (_) {
      if (mounted) _mostrarMensaje('No se pudo guardar. Inténtalo de nuevo');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  String _formatearFecha(DateTime fecha) {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year} '
        '${dos(fecha.hour)}:${dos(fecha.minute)}';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.producto.nombre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _construirImagen(),
          const SizedBox(height: 16),
          _construirInformacion(),
          const Divider(height: 32),
          _construirEstado(),
          const Divider(height: 32),
          _construirFormulario(),
        ],
      ),
    );
  }

  Widget _construirImagen() {
    final url = widget.producto.imagen;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: url.isEmpty
            ? _construirPlaceholder()
            : Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) =>
                    _construirPlaceholder(),
              ),
      ),
    );
  }

  Widget _construirPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, size: 60),
    );
  }

  Widget _construirInformacion() {
    final textos = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.producto.nombre, style: textos.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Precio: \$${widget.producto.precio.toStringAsFixed(2)}',
          style: textos.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Categoría: ${widget.producto.categoria}',
          style: textos.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text('Código: ${widget.producto.id}', style: textos.bodySmall),
      ],
    );
  }

  Widget _construirEstado() {
    final textos = Theme.of(context).textTheme;

    Widget contenido;
    if (_cargandoRegistro) {
      contenido = const Center(child: CircularProgressIndicator());
    } else if (_registro == null) {
      contenido = const Row(
        children: [
          Icon(Icons.info_outline),
          SizedBox(width: 8),
          Expanded(child: Text('No hay información guardada')),
        ],
      );
    } else {
      final registro = _registro!;
      final sincronizado = !registro.pendingSync;
      final color = sincronizado ? Colors.green : Colors.orange;

      contenido = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                sincronizado ? Icons.cloud_done : Icons.cloud_upload_outlined,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                sincronizado ? 'Sincronizado' : 'Pendiente',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Última actualización: ${_formatearFecha(registro.updatedAt)}',
            style: textos.bodySmall,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estado', style: textos.titleMedium),
        const SizedBox(height: 8),
        contenido,
      ],
    );
  }

  Widget _construirFormulario() {
    final textos = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Prioridad', style: textos.titleMedium),
        _construirSelectorPrioridad(),
        Text(
          'Prioridad $_prioridad de $_prioridadMaxima '
          '(mínimo $_prioridadMinimaParaGuardar para guardar)',
          style: textos.bodySmall,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _textoController,
          maxLines: 3,
          maxLength: _largoMaximoNota,
          decoration: const InputDecoration(
            labelText: 'Nota personal',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _guardando ? null : _guardar,
            child: _guardando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ),
      ],
    );
  }

  Widget _construirSelectorPrioridad() {
    return Row(
      children: List.generate(_prioridadMaxima, (index) {
        final nivel = index + 1;
        final seleccionada = nivel <= _prioridad;

        return IconButton(
          color: Colors.amber,
          icon: Icon(seleccionada ? Icons.star : Icons.star_border),
          onPressed: () => setState(() => _prioridad = nivel),
        );
      }),
    );
  }
}
