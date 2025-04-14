module UtilityService
  module South
    class ResponseMapper < UtilityService::ResponseMapper
      def retrieve_books(_response_code, response_body)
        { books: map_books(response_body['Libros']) }
      end

      def retrieve_notes(_response_code, response_body)
        { notes: map_notes(response_body['Notas']) }
      end

      private

      def map_books(books)
        books.map do |book|
          {
            id: book['Id'],
            title: book['Titulo'],
            author: book['Autor'],
            genre: book['Genero'],
            image_url: book['ImagenUrl'],
            publisher: book['Editorial'],
            year: book['Año']
          }
        end
      end

      def map_notes(notes)
        notes.map do |note|
          author_name = note['NombreCompletoAutor']
          first_name, last_name = get_name_values(author_name)
          {
            title: note['TituloNota'],
            type: get_note_type(note['ReseniaNota']),
            created_at: note['FechaCreacionNota'],
            content: note['Contenido'],
            user: {
              email: note['EmailAutor'],
              first_name: first_name,
              last_name: last_name
            },
            book: {
              title: note['TituloLibro'],
              author: note['NombreAutorLibro'],
              genre: note['GeneroLibro']
            }
          }
        end
      end

      def get_name_values(full_name)
        name_parts = get_array_name(full_name)
        last_name = name_parts[0]
        first_name = name_parts[1]
        [first_name, last_name]
      end

      def get_array_name(full_name)
        full_name.split(' ', 2)
      end

      def get_note_type(es_resenia)
        es_resenia ? 'review' : 'critique'
      end
    end
  end
end
