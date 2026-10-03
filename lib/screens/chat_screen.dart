  // --- MÉTODOS DE ELIMINACIÓN DE SESIÓN ---

  Future<void> _deleteSession(String sessionId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Eliminar sesión', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este hilo? Esta acción no se puede deshacer.',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteSession(sessionId);
      
      // Si la sesión eliminada era la activa, resetear o cambiar de sesión
      if (_currentSessionId == sessionId) {
        _currentSessionId = null;
      }
      
      await _loadSessions();
    }
  }

  // --- DRAWER CON BOTÓN DE ELIMINACIÓN ---

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1E293B)),
            child: Center(
              child: Text(
                'VVC-NOA HILOS',
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add, color: Color(0xFF38BDF8)),
            title: const Text(
              'Nueva Conversación',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              _createNewSession();
            },
          ),
          const Divider(color: Color(0xFF334155)),
          Expanded(
            child: ListView.builder(
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                final isSelected = session['id'] == _currentSessionId;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: const Color(0xFF1E293B),
                  leading: Icon(
                    Icons.chat_bubble_outline,
                    color: isSelected ? const Color(0xFF38BDF8) : Colors.grey,
                  ),
                  title: Text(
                    session['title'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFF64748B)),
                    onPressed: () => _deleteSession(session['id']),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _selectSession(session['id'], session['title']);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
