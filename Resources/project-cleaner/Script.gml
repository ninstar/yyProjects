var Target = get_open_filename("GameMaker Studio 2 Project (.yyp)|*.yyp", "");
if(Target != ""){

	var _ConfirmPNG = show_question("Remove unused graphics in the sprites folder? (Optional)");
	var _Confirm = show_question("It is recommended to close the selected project from the IDE before proceeding, a new window will appear when the process is finished. Press 'Yes' to start.");
	if(_Confirm){
	
		var Log_Removals = 0;
		var Log_Found = 0;
		var Log_Queue = [];
		var LogPNG_Removals = 0;
		var LogPNG_Found = 0;
		var LogPNG_Queue = [];
		var AssetName = [];
		var Filter = [

			"animcurves",
			"extensions",
			"fonts",
			"notes",
			"objects",
			"paths",
			"rooms",
			"scripts",
			"sequences",
			"shaders",
			"sprites",
			"tilesets"
		];

		for(var t = 0; t < array_length(Filter); ++t){

			// Asset filter
			var _TypeDir = filename_path(Target)+Filter[t]+"\\";
			var _SearchPNG = (Filter[t] == "sprites");
	
			// Search within current filter directory
			var _Index = 0;
			var _Find = file_find_first(_TypeDir+"*", fa_directory);
			while(_Find != ""){
		
				// Save asset name (based on their folder name)
				AssetName[_Index] = filename_name(_Find);
		
				// Search for next asset folder...
				_Find = file_find_next();
				_Index++;
			}
			file_find_close();
	
			// Target asset folder
			for(var a = 0; a < array_length(AssetName); ++a){
	
				// Search for .yy files within the current asset folder
				var _aPNG = "";
				var _aFind = file_find_first(_TypeDir+AssetName[a]+"\\*.yy", 0);
				while(_aFind != ""){
		
					// Remove if the file name does not match the same asset folder name
					if(string_lower(_aFind) != string_lower(AssetName[a]+".yy")){
				
						// Log
						Log_Queue[Log_Removals] = Filter[t]+" -> "+AssetName[a]+" -> "+_aFind;
					
						// Remove
						file_delete(_TypeDir+AssetName[a]+"\\"+_aFind);
						Log_Removals++;
					}
					else{
					
						// Remember the .yy that matches the asset folder name
						if(_SearchPNG)
							_aPNG = _aFind;
					}
			
					Log_Found++;
					
					// Search next file...
					_aFind = file_find_next();
				}
				file_find_close();
				
				// Remove leftovers .png (Sprite assets only)
				if(_ConfirmPNG)
				&&(_aPNG != ""){
				
					// Search for .png files within the current asset folder
					var _pngFile = [];
					var _pngRefs = [];
					var _pngCount = 0;
					var _pngFind = file_find_first(_TypeDir+AssetName[a]+"\\*.png", 0);
					while(_pngFind != ""){
			
						// Save file name
						_pngFile[_pngCount] = _pngFind;
						_pngRefs[_pngCount] = 0;
						
						LogPNG_Found++;
						
						// Search next file...
						_pngCount++;
						_pngFind = file_find_next();
					}
					file_find_close();
				
					// Check all possible references in the .yy file
					var _aFile = file_text_open_read(_TypeDir+AssetName[a]+"\\"+_aPNG);
					var _aLine = 0;
					var _aLineString = "";
					while(!file_text_eof(_aFile)){
		
						_aLineString = file_text_readln(_aFile);
						
						// Search for references for each one of the files
						for(var p = 0; p < array_length(_pngFile); ++p){

							// Remember if it was referenced
							if(string_pos(string_replace(_pngFile[p], ".png", ""), _aLineString) > 0)
								_pngRefs[p]++;
						}
					
						// Next line...
						_aLine++;
					}
					file_text_close(_aFile);
					
					for(var p = 0; p < array_length(_pngFile); ++p){
						
						// Remove the .png file if it was no references
						if(_pngRefs[p] == 0){
		
							// Log
							LogPNG_Queue[LogPNG_Removals] = Filter[t]+" -> "+AssetName[a]+" -> "+_pngFile[p];
						
							// Remove .png
							file_delete(_TypeDir+AssetName[a]+"\\"+_pngFile[p]);
	
							// Remove layers
							var _Layers = _TypeDir+AssetName[a]+"\\layers\\"+string_replace(_pngFile[p], ".png", "");
							if(directory_exists(_Layers))
								directory_destroy(_Layers);
							
							LogPNG_Removals++;
						}
					}
				}
			}
		}
	
		// Save log
		var TxtFile = file_text_open_write(Target+".removals.txt");
		var i;
		
		file_text_write_string(TxtFile, ".yy Removals: "+string(Log_Removals)+" / "+string(Log_Found)+" files.");
		
		repeat(2)
				file_text_writeln(TxtFile);
		
		for(i = 0; i < array_length(Log_Queue); ++i){
		
			file_text_write_string(TxtFile, Log_Queue[i]);
			file_text_writeln(TxtFile);
		}
		
		if(_ConfirmPNG){
			
			file_text_writeln(TxtFile);
	
			file_text_write_string(TxtFile, ".png Removals: "+string(LogPNG_Removals)+" / "+string(LogPNG_Found)+" files.");
			
			repeat(2)
				file_text_writeln(TxtFile);
				
			for(i = 0; i < array_length(LogPNG_Queue); ++i){
		
				file_text_write_string(TxtFile, LogPNG_Queue[i]);
				file_text_writeln(TxtFile);
			}
		}
		
		file_text_close(TxtFile);
		show_message("Cleaning completed, a log file has been generated in the project directory. ["+filename_name(Target)+".removals.txt]");
	}
}