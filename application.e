note
	description: "comandos application root class"
	date: "$Date$"
	revision: "$Revision$"
class
	APPLICATION
inherit
	ARGUMENTS_32
create
	make
feature {NONE}
	make
		local
			linea : STRING
			lista_nombres_files: LINKED_LIST[STRING]
			lista_objetos_documentos: LINKED_LIST[LINKED_LIST[JSON_OBJECT]]
		do
			from
				create lista_nombres_files.make
				create lista_objetos_documentos.make
				io.put_string ("> ")
				io.read_line
				linea := io.last_string
			until
				linea.is_equal ("exit")
			loop
				io.put_string ("    " + linea + "%N")
				ejecutar_cmd(linea, lista_nombres_files, lista_objetos_documentos)
				io.put_string ("%N> ")
				io.read_line
				linea := io.last_string
			end
		end
feature
	ejecutar_cmd (s:STRING; lista_nombres_files:LINKED_LIST[STRING]; lista_objetos_documentos:LINKED_LIST[LINKED_LIST[JSON_OBJECT]])
	local
		tokens: LIST[STRING]
		com: STRING
		a : INTEGER
		t : STRING
		nombre_file: STRING
		primera_letra_file: STRING
		flag: BOOLEAN
		nombre_documento: STRING
		lista_nombres: LINKED_LIST[STRING]
		lista_tipos: LINKED_LIST[STRING]

	do
		flag:= True
		tokens := s.split (' ')
		from
			tokens.start
		until
			tokens.off
		loop
			io.put_string ("      " + tokens.item + "%N")
		    tokens.forth
		end
		tokens.start
		com := tokens.item
		if com.is_equal ("load") then
		    io.put_string ("    comando_load%N")
		    nombre_file:=tokens.i_th (2)
		    nombre_documento:=tokens.i_th (3)
		    io.put_string (nombre_file)
		    primera_letra_file:=nombre_file.head(1)
	    	if primera_letra_file.is_integer then
	    		io.put_string ("El primer caracter del nombre del archivo no es una letra")
			else
				io.put_string ("El primer caracter del nombre del archivo es una letra")
				from
					lista_nombres_files.start
				until
					lista_nombres_files.after
				loop
					if lista_nombres_files.item.is_equal(nombre_file) and flag=True then
						flag:=False
						io.put_string ("Se rechaza el comando porque ya existe un archivo con ese nombre")
					end
					lista_nombres_files.forth
				end
				if flag=True then
					lista_nombres_files.extend (nombre_file)
					create lista_nombres.make
					create lista_tipos.make
					cmd_load(nombre_documento, lista_nombres, lista_tipos)
				end
	    	end

		elseif com.is_equal ("save") then
		    io.put_string ("    comando_save%N")
		elseif com.is_equal ("savecsv") then
		    io.put_string ("    comando_savecsv%N")
		elseif com.is_equal ("select") then
		    io.put_string ("    comando_select%N")
		elseif com.is_equal ("project") then
		    io.put_string ("    comando_project%N")
		elseif com.is_equal ("help") then
		    io.put_string ("    comando_help: load save savecsv select project help exit%N")
		else
		    io.put_string ("    comando_desconocido%N")
		end
	end
feature
	cmd_load (nombre_documento:STRING; lista_nombres: LINKED_LIST[STRING]; lista_tipos: LINKED_LIST[STRING])
	local
		lista_objetos: LINKED_LIST[JSON_OBJECT]
		fila_json: JSON_OBJECT
	   	entrada: PLAIN_TEXT_FILE
	   	words: LIST[STRING]
		flag: INTEGER
		contador: INTEGER
		nombre_columna: STRING
		lista_prueba: LIST[STRING]
	do
		flag:=0
		create lista_objetos.make

		create entrada.make_open_read (nombre_documento.out)
  		from
        	entrada.read_line
        until
            entrada.exhausted
        loop
        	if flag=0 then
        		lista_prueba:= entrada.last_string.split (';')
        		from
        			lista_prueba.start
        		until
        			lista_prueba.after
        		loop
        			lista_nombres.extend (lista_prueba.item)
        			lista_prueba.forth
        		end
        	   	entrada.read_line
	           	lista_prueba:= entrada.last_string.split (';')
        		from
        			lista_prueba.start
        		until
        			lista_prueba.after
        		loop
        			lista_tipos.extend (lista_prueba.item)
        			lista_prueba.forth
        		end
	       		entrada.read_line
        	end
       		flag:=1
         	contador:=1
           	words := entrada.last_string.split (';')

			from
				words.start
			until
				words.after
			loop
				create fila_json.make_empty
				lista_nombres.go_i_th (contador)
				io.put_string(lista_nombres.index.out)
				fila_json.put_string (words.item,lista_nombres.item.out)
				lista_objetos.extend (fila_json)
				words.forth
				contador:= contador+1
			end
			contador:=1
			entrada.read_line
		end
		across
			lista_objetos as json_objeto
		loop
			io.put_string (json_objeto.item.representation)
		end
		entrada.close
	end
end

