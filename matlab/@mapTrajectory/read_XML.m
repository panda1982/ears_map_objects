function obj = read_XML( obj, filename )

%% Read XML to struct
%
xmlStruct = read_XML2struct( filename );

%% Read struct to class
%
% xmlStruct is a linear structure, i.e., not nested. Convert all children
% to map objects and create structure of objects:
num_mapObjects = length(xmlStruct.Children);

% NOTE: Do not use obj(1:num_mapObjects) = map() here as this
% creates an array of copies of a hgsetget class (which map inherits from) 
% - if one gets changed all get changed!
for map_ind = 1 : num_mapObjects,
    obj(map_ind) = mapTrajectory();
end;

for map_ind = 1 : num_mapObjects,
    names   = { xmlStruct.Children(map_ind).Children(:).Name };
    data    = {xmlStruct.Children(map_ind).Children(:).Data};

    % Use 'eval' instead of str2* to convert from char to numerical fields
    % and to allow for vectors & matrices to be converted appropriately.
    for field_ind = 1 : length(names),

        if ischar(obj(map_ind).(names{field_ind})),
            % Remove inverted commata inherited from XML for strings:
            data{field_ind} = regexprep(data{field_ind},'[^a-zA-z]','');
        else
            if isa(obj(map_ind).(names{field_ind}), 'uint32'),
                data{field_ind} = uint32(eval(data{field_ind}));
            elseif isa(obj(map_ind).(names{field_ind}), 'double'),
                data{field_ind} = eval(data{field_ind});
            end
            % Convert vectors / matrices to correct dimensions:
            if numel(data{field_ind}) > 1
                [num_rows, num_cols] = size(data{field_ind});
                
                % Only accept column vectors and matrices of dimension MxM.
                % Transpose any row vectors and reject MxN matrices:
                if num_rows == 1 && num_cols > 1,
                    data{field_ind} = data{field_ind}.';
                end;
                
                if ( num_rows > 1 ) && ( num_cols > 1 ) && ( num_rows ~= num_cols )
                    error('Matrices must have equal number of rows and columns');
                end;
                
                obj(map_ind).order = num_rows;
            end
        end;
        
        % xmlStruct stores properties as strings - convert to datatype:
        obj(map_ind).(names{field_ind}) = data{field_ind};
    end;
end;

end