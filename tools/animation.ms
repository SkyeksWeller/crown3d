global isExportHide = true		-- �Ƿ񵼳���������
global isExportKeyFrame = false		-- �Ƿ�ֻ�����ؼ�֡
global frameSampleRate = 5			-- ��֡����������
global isExportBlt = true			-- �Ƿ񵼳��󶨵�
global isExportBla = true			-- �Ƿ񵼳�����
global isExportBlm = true			-- �Ƿ񵼳�ģ��
global isExportBlq = false			-- �Ƿ񵼳�����
global isSkinCheck = true			-- �Ƿ���skin���ݼ��


global CrownExport		-- ����
global savePath = ""	-- �����Ŀ¼
global avatarFileName = ""		-- Ҫ����Ľ�ɫ�ļ���
global textureFileName = ""		-- ��ͼ��
global mesh_array = #()		-- Ҫ������mesh����
global bone_array = #()		-- �����еĹ�ͷ
global helper_array = #()	-- �����󶨵�
global aniString = stringstream""	-- ��ɫ�ļ��ִ�
global meshString = stringstream""	-- ģ���ļ��ִ�
global errString = stringstream""	-- ��������
global baseFrame = 0		-- �趨��0֡ΪĬ��֡

global isBinary = true	-- �ֽ���
global chunkid_bla_mesh = 0x0100
global chunkid_bla_hierarchy = 0x0200
global chunkid_bla_bones = 0x0300
global chunkid_bla_bonetags = 0x0400
global chunkid_blq_animation = 0x0500
global chunkid_blq_bone = 0x0600
global chunkid_blq_time = 0x0700
global chunkid_blm_vertex = 0x0800
global chunkid_blm_index = 0x0900

-- ������������
function vdistance v1 v2 =
(
	dis = sqrt( (pow (v1[1]-v2[1]) 2) + (pow (v1[2]-v2[2]) 2) + (pow (v1[3]-v2[3]) 2) )
	return dis
)
-- ȥ���ַ���ͷβ�Ŀո�
function filterSpace instring =
(
	outstring = instring 
	while (outstring[1] == " ") do
	(
		outstring = substring outstring 2 -1
	)
	while (outstring[outstring.count] == " ") do
	(
		outstring = substring outstring 1 (outstring.count-1)
	)
	return outstring
)
-- ת��Сд
function lowercase instring = -- beginning of function definition
(
	local upper, lower, outstring -- declare variables as local
	upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ" -- set variables to literals
	lower="abcdefghijklmnopqrstuvwxyz"
	outstring = copy instring
	for i=1 to outstring.count do
	(
		j = findString upper outstring[i]
		if (j != undefined) do outstring[i]=lower[j]
	)
	return outstring

) -- end of fn lowercase
-- ���ý�����
function progress pro =
(
	CrownExport.progExport.value = pro	-- ������
)
-- �������ݼ��
function SkinCheck =
(
	-- ��鵼�����ݺϷ���
	geocount = geometry.count
	--format "geocount = %\n" geocount 
	mi = 1
	proi = 1	
	for meshi in geometry do
	(
		progress( 20 * proi / geocount )	-- ������
		proi += 1
		-- �Ƿ񵼳���������
		if meshi.isHidden and isExportHide == false do
		(
			format "% ����\n" meshi.name
			continue
		)
		-- ������Editable_mesh
		if ( ((classof meshi ) as string) != "Editable_mesh" ) do
			continue
		if meshi.modifiers == undefined do continue
		
		format "���%\n" meshi.name

		checkok = true
		-- ���ҽ���һ��skin
		mods = meshi.modifiers
		if mods.count != 1 do continue
		skin = mods[1]
		if (classof skin as string != "Skin") do
		(
			format "mesh %�������ҽ���һ��skin,������\n" meshi.name
			format "mesh %�������ҽ���һ��skin,������\n" meshi.name to:errString
			continue
		)
		
		select meshi-- ѡ�и�mesh
		setCommandPanelTaskMode mode:#modify
		modPanel.setCurrentObject skin 	-- ѡ��skin����
		
		-- �Ƿ�����ͼ
		--format "�Ƿ�����ͼ\n"
		isHaveUV = (meshop.getMapSupport meshi 1)
		if isHaveUV == false then
		(
			format "mesh %û��UV���ݲ�����\n" meshi.name
			format "mesh %û��UV���ݲ�����\n" meshi.name to:errString
			checkok = false
			continue
		)
		
		-- ���ֻ����һ������
		--format "���ֻ����һ������\n"
		faceNum = getNumFaces meshi
		isOnlyOneMat = true
		matId = -1
		for fi=1 to faceNum do
		(		
			if fi == 1 then
				matId = getFaceMatID meshi fi
			else
			(
				if matId != (getFaceMatID meshi fi) then
				(
					format "mesh %�ж�����ʲ�����\n" meshi.name
					format "mesh %�ж�����ʲ�����\n" meshi.name to:errString
					isOnlyOneMat = false
					exit
				)
			)
		)
				
		if isOnlyOneMat == false then
		(
			checkok = false
			continue
		)
		-- �������mesh�Ƿ�����ͬһ����ͼ
		--format "�������mesh�Ƿ�����ͬһ����ͼ\n"
		if( (classof meshi.material) as string != "Standardmaterial" ) then
		(
			format "% �Ĳ��ʲ���Standardmateria\n" meshi.name
			format "% �Ĳ��ʲ���Standardmateria\n" meshi.name to:errString
			checkok = false
			continue
		)
		
		if( (classof meshi.material.diffuseMap) as string != "Bitmaptexture" ) then
		(
			format "% �Ĳ��ʵ�diffusemap����Bitmaptexture\n" meshi.name
			checkok = false
			continue
		)
		if mi == 1 then
		(
			textureFileName = meshi.material.diffuseMap.filename
			format "������ͼΪ%\n" textureFileName 
		)
		else
		(
			-- ������ͼ���
			--if textureFileName != meshi.material.diffuseMap.filename then
			--(
			--	format "% ����ͼ%������ģ�͵���ͼ����\n" meshi.name textureFileName 
			--	format "% ����ͼ%������ģ�͵���ͼ����\n" meshi.name textureFileName to:errString
			--	checkok = false
			--	continue
			--)
		)
		
		-- �������Ƿ�ƥ��
		--format "�������Ƿ�ƥ��\n"
		boneCount = skinOps.GetNumberBones skin
		
		if mi == 1 then
		(
			-- ��¼��ͷ
			for bi=1 to boneCount do
			(
				boneName = skinOps.GetBoneName skin bi 0
				format "��ͷ:%\n" boneName
				append bone_array boneName
			)
			format "��ͷ��:%\n" bone_array.count
		)
		else
		(
			-- ����ͷ�����
			if boneCount != bone_array.count do
			(
				format "mesh % ��skin�й���������\n" meshi.name
				format "mesh % ��skin�й���������\n" meshi.name to:errString
				checkok = false
			)
			-- ����ͷ�������			
			for bi=1 to boneCount do
			(
				boneName = skinOps.GetBoneName skin bi 1
				index = findItem bone_array boneName
				if index == 0 then
				(
					format "mesh % ��skin���еĹ�ͷ%������skin����\n" meshi.name boneName
					format "mesh % ��skin���еĹ�ͷ%������skin����\n" meshi.name boneName to:errString
					checkok = false
				)
			)
		)
				
		-- ���ÿ�������ϵ�Ȩֵ���ܳ���4��
		--format "���ÿ�������ϵ�Ȩֵ���ܳ���4��\n"
		vertexNum = getNumVerts meshi
		format "vertexNum=%\n" vertexNum 
		for vi=1 to vertexNum do
		(
			weightCount = skinops.getvertexweightcount skin vi
			if weightCount > 4 then
			(
				format "mesh %�ĵ�%������Ĺ���Ȩ��������4��\n" meshi.name (vi-1)
				format "mesh %�ĵ�%������Ĺ���Ȩ��������4��\n" meshi.name (vi-1) to:errString
				checkok = false
			)
		)
		
		-- ��¼Ҫ������mesh
		if checkok then
		(
			append mesh_array meshi
			format "�����б������%��mesh: %\n" mi meshi.name
		)
		else
		(
			format "mesh: % %��������������\n" mi meshi.name
			format "mesh: % %��������������\n" mi meshi.name to:errString
		)
		
		mi += 1
	)
	-- �Թ�������(��֤parent��ͷ��ǰ��)
	newBone_array = #()
	lastBoneArrayCount = bone_array.count
	while bone_array.count > 0 do
	(
		for bi=1 to bone_array.count do
		(
			boneNode = getnodebyname bone_array[bi]
			isInsert = false
			--format "boneNode=%\n" boneNode.name
			if boneNode.parent == undefined then
			(
				append newBone_array boneNode.name
				--format "insert ���ڵ� %\n" boneNode.name
				isInsert = true
			)
			else
			(
				if (findItem newBone_array boneNode.parent.name) != 0 then
				(
					append newBone_array boneNode.name
					--format "insert �ӽڵ� % %\n" boneNode.name boneNode.parent
					isInsert = true
				)				
			)
			
			if isInsert then
			(	
				bone_array = deleteItem bone_array bi
				exit
			)
		)
		
		--format "bone_array.count=%\n" bone_array.count
		if lastBoneArrayCount == bone_array.count then
		(
			format "skin�еĹ�����ȫ\n"
			format "skin�еĹ�����ȫ\n" to:errString
			newBone_array.count = 0
			exit
		)

		lastBoneArrayCount = bone_array.count		
	)

	bone_array = newBone_array
	
	-- ���Ҫ�����Ĺ����󶨵�
	helper_array = #()
	for helper in helpers do
	(
		if helper.parent == undefined then continue	-- dummy����û��parent
		if findItem bone_array helper.parent.name == 0 then continue -- dummy��parent����Ҫ�����Ĺ���
		-- �ų�cs����Ĭ�ϵ�dummy��
		if helper.name == "Bip01 HeadNub" or 
			helper.name == "Bip01 R Finger0Nub" or
			helper.name == "Bip01 L Finger0Nub" or
			helper.name == "Bip01 R Toe0Nub" or
			helper.name == "Bip01 L Toe0Nub" or
			helper.name == "Bip01 R Finger1Nub" or
			helper.name == "Bip01 L Finger1Nub"			
		then continue
		
		append helper_array helper.name
		--format "%\n" helper.name
	)
		
	-- ��ʾҪ�����mesh�͹�ͷ
	format "Ҫ������mesh(����%):\n" mesh_array.count
	for mi=1 to mesh_array.count do
	(
		format "%\n" mesh_array[mi].name
	)
	format "Ҫ�����Ĺ�ͷ(����%):\n" bone_array.count
	for bi=1 to bone_array.count do
	(
		format "%\n" bone_array[bi]
	)
	format "Ҫ�����Ĺ����󶨵�(����%):\n" helper_array.count
	for hi=1 to helper_array.count do
	(
		format "%\n" helper_array[hi]
	)
	
	if mesh_array.count == 0 do
	(	
		format "����mesh��Ϊ0\n"
		return false
	)
	
	if bone_array.count == 0 or bone_array.count > 38 do
	(
		format "��ͷ������38��Ϊ0\n"
		format "��ͷ������38��Ϊ0\n" to:errString
		return false
	)
	
	if helper_array.count == 0 then
	(
		format "����������һ���Ϸ������󶨵�\n"
		format "����������һ���Ϸ������󶨵�\n" to:errString
		return false
	)
		
	return true
)
-- ����Mesh����ͼ
function TextureExport edmesh =
(
	-- ������ͼ
	srcAllFileName = edmesh.material.diffuseMap.filename
	srcFileName = getFilenameFile srcAllFileName + getFilenameType srcAllFileName

	--desFileName = getFilenameFile srcAllFileName + getFilenameType srcAllFileName 
	--desFileName = getFilenameFile srcAllFileName + ".tga"	-- ��ͼ��Ϊtga
	desFileName = getFilenameFile srcAllFileName + ".dds"	-- ��ͼ��Ϊdds

	desAllFileName = savePath + desFileName
	desAllFileName = lowercase desAllFileName		-- Сд
	-- �����ͼ������
	justFileName = getFilenameFile desFileName
	justExtName = getFilenameType desFileName

	format "����ģ�� % ����ͼ %\n" edmesh.name desAllFileName 
	
	-- ���Դ��ͼ�Ƿ����
	isExist = false
	if( doesFileExist srcAllFileName ) then isExist = true

	testFileName = sysInfo.currentdir + "\\" + srcFileName;
	if( doesFileExist testFileName ) then isExist = true

	testFileName = maxFilePath + srcFileName;
	if( doesFileExist testFileName ) then isExist = true
 
	if(isExist == false) then
	(
		format "��ͼ % ������\n" srcAllFileName
		format "��ͼ % ������\n" srcAllFileName to: errString
		return undefined
	)

	srcBmp = edmesh.material.diffuseMap.bitmap
	desBmp = bitmap srcBmp.width srcBmp.height filename:desAllFileName 
		
	copy srcBmp desBmp
	save desBmp
	close desBmp
	
	format "������ͼ % ����\n" desAllFileName	
	return desAllFileName
)
function MyWriteString file string =
(
	WriteShort file string.count unsigned 	-- �ַ�������
	WriteString file string					-- �ַ���
)
-- �����ļ�ͷ
function WriteAniHeader file =
(
	if isBinary then
	(		
		WriteLong file 2 unsigned		-- �汾��
		WriteLong file bone_array.count 	-- ������
		MyWriteString file (getFilenameFile textureFileName) 		-- ��ͼ��
		
		-- mesh����chunk
		WriteShort file chunkid_bla_mesh unsigned
		WriteLong file mesh_array.count unsigned
		-- mesh��������
		for mi=1 to mesh_array.count do
		(
			MyWriteString file mesh_array[mi].name
		)
	)
	else
	(
		format "blaversion %\n" 1 to:file
		format "\n" to:file
		format "boneNum %\n" bone_array.count to:file
		format "\n" to:file
		format "tex \"%\"\n" (getFilenameFile textureFileName) to:file
		format "\n" to:file
			
		format "mesh {\n" to:file
		for mi=1 to mesh_array.count do
		(
			format "\t%\n" mesh_array[mi].name to:file
		)
		format "}\n" to:file
		format "\n" to:file
	)

)
-- ������ϵ
function WriteBoneHierarchy file =
(
	if isBinary then
	(
		-- �����̳й�ϵchunk
		WriteShort file chunkid_bla_hierarchy unsigned
		WriteLong file bone_array.count unsigned
		-- �����̳й�ϵ����
		for bi=1 to bone_array.count do
		(			
			boneNode = getnodebyname bone_array[bi]
			if boneNode.parent == undefined then
			(				
				MyWriteString file bone_array[bi]
				WriteShort file -1
			)
			else
			(
				parentIndex = findItem bone_array boneNode.parent.name
				MyWriteString file bone_array[bi]
				WriteShort file (parentIndex-1)
			)
		)
	)
	else
	(
		format "hierarchy {\n" to:file
		for bi=1 to bone_array.count do
		(
			boneNode = getnodebyname bone_array[bi]
			if boneNode.parent == undefined then
			(
				format "\t\"%\" %\n" bone_array[bi] -1 to:file
			)
			else
			(
				parentIndex = findItem bone_array boneNode.parent.name
				format "\t\"%\" %\n" bone_array[bi] (parentIndex-1) to:file
			)			
		)
		format "}\n" to:file
		format "\n" to:file
	)
)
-- ��������
function WriteBonePosition file =
(
	if isBinary then
	(
		-- ��������chunk
		WriteShort file chunkid_bla_bones unsigned
		WriteLong file bone_array.count unsigned
		-- ��������
		for bi=1 to bone_array.count do
		(
			boneNode = getnodebyname bone_array[bi]
			boneMat = boneNode.transform
			bonePos = boneMat.translation
			boneRot = boneMat.rotationpart
			if boneRot.w < 0 then boneRot = -boneRot
			
			WriteFloat file bonePos.x
			WriteFloat file bonePos.z
			WriteFloat file bonePos.y
			WriteFloat file -boneRot.x
			WriteFloat file -boneRot.z
			WriteFloat file -boneRot.y
		)	
	)
	else
	(
		format "bones {\n" to:file
		for bi=1 to bone_array.count do
		(
			boneNode = getnodebyname bone_array[bi]
			boneMat = boneNode.transform
			bonePos = boneMat.translation
			boneRot = boneMat.rotationpart
			if boneRot.w < 0 then boneRot = -boneRot
			
			--format "%\n" boneNode.transform
			
			format "\t% ( % % % ) ( % % % )\n" \
			(bi-1) \
			bonePos.x bonePos.z bonePos.y \
			-boneRot.x -boneRot.z -boneRot.y \
			to:file
			--boneNode.rotation.x boneNode.rotation.y boneNode.rotation.z boneNode.rotation.w \
		)	
		format "}\n" to:file
		format "\n" to:file
	)
)
-- �����󶨵�
function WriteHelper file =
(
	if isBinary then
	(
		-- �����󶨵�chunk
		WriteShort file chunkid_bla_bonetags unsigned
		WriteLong file helper_array.count unsigned
		-- �����󶨵�����
		for hi=1 to helper_array.count do
		(
			format "���������󶨵� %\n" helper_array[hi]
			helperNode = getnodebyname helper_array[hi]
			
			helperMat = helperNode.transform
			parentMat = helperNode.parent.transform
			parentMatInv = inverse parentMat
			helperMat = helperMat * parentMatInv
			helperPos = helperMat.translation
			helperRot = helperMat.rotationpart
			if helperRot.w < 0 then helperRot = -helperRot 
			
			parentBoneIndex = findItem bone_array helperNode.parent.name
			
			MyWriteString file helperNode.name
			WriteShort file (parentBoneIndex-1)
			
			WriteFloat file helperPos.x
			WriteFloat file helperPos.z
			WriteFloat file helperPos.y
			WriteFloat file -helperRot.x
			WriteFloat file -helperRot.z
			WriteFloat file -helperRot.y
		)
	)
	else
	(
		format "bonetags {\n" to:file
		for hi=1 to helper_array.count do
		(
			format "���������󶨵� %\n" helper_array[hi]
			helperNode = getnodebyname helper_array[hi]
			
			helperMat = helperNode.transform
			parentMat = helperNode.parent.transform
			parentMatInv = inverse parentMat
			helperMat = helperMat * parentMatInv
			helperPos = helperMat.translation
			helperRot = helperMat.rotationpart
			if helperRot.w < 0 then helperRot = -helperRot 
			
			parentBoneIndex = findItem bone_array helperNode.parent.name
			
			format "\t\"%\" % ( % % % ) ( % % % )\n" \
			helperNode.name (parentBoneIndex-1)  \
			helperPos.x helperPos.z helperPos.y \
			-helperRot.x -helperRot.z -helperRot.y\
			to:file
		)
		format "}\n" to:file
		format "\n" to:file
	)
)
-- ������������
function WriteBoneAnimation file aniName startTime endTime =
(
	if endTime < startTime then return undefined
		
	mustExportKeyFrame = false
	if (findItem CrownExport.animList.items aniName) != 0 then
		mustExportKeyFrame = true
	
	format "��������:% startTime=% endTime=% kf=%\n" \
		aniName startTime endTime (mustExportKeyFrame or isExportKeyFrame)
	
	-- ����chunk	
	if isBinary then
	(
		WriteShort file chunkid_blq_animation unsigned
		WriteLong file bone_array.count unsigned
		MyWriteString file aniName
	)
	else
	(
		format "animation \"%\" {\n" aniName to:file
	)
		
	for bi=1 to bone_array.count do
	(
		-- �ö����Ĺ�ͷchunk
		keyCountFilePos
		if isBinary then
		(
			WriteShort file chunkid_blq_bone unsigned
			keyCountFilePos = ftell file			
			WriteLong file 0 unsigned
		)
		else
		(
			format "\tbone % {\n" (bi-1) to:file
		)
		
		boneNode = getnodebyname bone_array[bi]
		select boneNode
		
		keyFrame = startTime 	-- start time
		lastKeyFrame = keyFrame 
		isEnd = false

		maxKey = 0
		do
		(
			set time keyFrame
			--format "bone=% time=% %\n" (bi-1) keyFrame boneNode.parent
			
			boneMat = boneNode.transform
			bonePos = boneMat.translation
			boneRot = boneMat.rotationpart
			if boneNode.parent != undefined then
			(
				parentMat = boneNode.parent.transform
				parentMatInv = inverse parentMat
				boneMat = boneMat * parentMatInv
				bonePos = boneMat.translation
				boneRot = boneMat.rotationpart
			)
			
			if boneRot.w < 0 then boneRot = -boneRot
 			
			-- SWAP YZ
			if isBinary then
			(
				WriteLong file keyFrame
				
				WriteFloat file bonePos.x
				WriteFloat file bonePos.z
				WriteFloat file bonePos.y
				WriteFloat file -boneRot.x
				WriteFloat file -boneRot.z
				WriteFloat file -boneRot.y
			)
			else
			(
				format "\t\ttime % ( % % % ) ( % % % )\n" keyFrame \
				bonePos.x bonePos.z bonePos.y \
				-boneRot.x -boneRot.z -boneRot.y  \
				to:file
			)

			-- ��һ�ؼ�֡
			lastKeyFrame = keyFrame
			if mustExportKeyFrame or isExportKeyFrame then
			(	-- ֻ�����ؼ�֡
				nextKeyTimeStr = trackbar.getNextKeyTime()
				if nextKeyTimeStr == undefined then
				(
					keyFrame = endTime+1
				)
				else
				(
					keyFrameStr = (nextKeyTimeStr as string)		-- 5f				
					keyFrameStr = substring keyFrameStr 1 (keyFrameStr.count-1)	-- ȥ��f
					keyFrame = keyFrameStr as number
				)
			)
			else
			(	-- ��֡����
				if frameSampleRate < 1 then frameSampleRate = 1
				keyFrame = lastKeyFrame + frameSampleRate
			)
			
			if isEnd == false and keyFrame >= endTime then
			(				
				keyFrame = endTime
				isEnd = true;
			)
			
			maxKey += 1
			--format "keyFrame= % endTime=%\n" keyFrame endTime
		)
		while (keyFrame <= endTime and keyFrame >= lastKeyFrame and maxKey < 100)	-- maxKey���ؼ�֡
		
		if isBinary then
		(	
			ret = fseek file keyCountFilePos #seek_set 		-- �ص�дkeyframe����
			if ret == false then throw "fseek error"
			
			ret = WriteLong file maxKey unsigned					-- д��keyframe��
			
			ret = fseek file 0 #seek_end 				-- �ص��ļ�β
			if ret == false then throw "fseek error"
		)
		else
		(
			format "\t}\n" to:file
		)
	)
	
	if isBinary then
	(
	)
	else
	(
		format "}\n" to:file
	)
)
-- ����ģ��
struct blVertexData
(
	vertex,
	uv,
	weights,
	boneIndexs,
	boneOffsets
)

function ExportMesh mesh file =
(
	mods = mesh.modifiers
	skin = mods[1]
	
	select mesh-- ѡ�и�mesh
	setCommandPanelTaskMode mode:#modify
	modPanel.setCurrentObject skin 	-- ѡ��skin����


	vertexNum = getNumVerts mesh		-- ������
	--format "vertices=%\n" vertexNum
	faceNum = getNumFaces mesh			-- ��������
	--format "face=%\n" faceNum
	
		
	-- ����
	blVertices = #()	-- ��������
	blIndices = #()	-- ��������
	
	--format "NumMaps=%\n" (meshop.getNumMaps mesh)
 	MapVertNum = meshop.getNumMapVerts mesh 1
	--format "NumMapVerts=%\n" MapVertNum 
	
	if false do	-- ������
	(
		-- ��ʾ���ж���
		format "vertex\n"
		for vi=1 to vertexNum do
		(
			vertex = getVert mesh vi
			weightCount = skinops.getvertexweightcount skin vi
			boneIDs = #()
			weights = #()
			for wi=1 to weightCount do
			(
				boneid = skinops.getvertexweightboneid skin vi wi
				weight = skinops.getvertexweight skin vi wi
				append boneIDs boneid
				append weights weight
			)
			
			format "% % % % %\n" vi vertex weightCount boneIDs weights 
		)
		-- ��ʾ����UV
		format "uv\n"
		for mi=1 to MapVertNum do
		(
			tvertex = meshop.getmapvert mesh 1 mi	
			format "% %\n" mi tvertex
		)
		-- ��ʾ����
		format "bone\n"
		for bi=1 to bone_array.count do
		(
			boneNode = getnodebyname bone_array[bi]
			format "% %\n" bi boneNode.transform
		)

	)
	
	for fi=1 to faceNum do
	(
		vertindices = getFace mesh fi		-- ��������
		tvertindices = meshop.getmapface mesh 1 fi --uv����
		-- ����������������
		v1 = #()
		v2 = #()
		v3 = #()
		for fvi=1 to 3 do
		(
			vert = getVert mesh vertindices[fvi]
			uv = meshop.getmapvert mesh 1 tvertindices[fvi]
			
			if fvi==1 do v1=vert
			if fvi==2 do v2=vert
			if fvi==3 do v3=vert		
			
			weightCount = skinops.getvertexweightcount skin vertindices[fvi]
			boneIndexs = #()
			weights = #()
			boneOffsets = #()
			for wi=1 to weightCount do
			(
				boneid = skinops.getvertexweightboneid skin vertindices[fvi] wi
				weight = skinops.getvertexweight skin vertindices[fvi] wi
				boneName = skinops.getbonename skin boneid 0
				boneNode = getnodebyname boneName
				invBoneMat = inverse boneNode.transform
				boneOffset = vert * invBoneMat
				boneIndex = findItem bone_array boneName

				append boneIndexs boneIndex
				append weights weight
				append boneOffsets boneOffset
			)			
			--format "face=% vi=% verti=% vert=% uvi=% uv=% boneIDs=% w=% offset=%\n" \
			--	fi fvi vertindices[fvi] vert tvertindices[fvi] uv boneIDs weights boneOffsets 
			
			blIndex = 0
			for blVi=1 to blVertices.count do
			(
				if (blVertices[blVi].vertex == vert and blVertices[blVi].uv == uv) do
				(
					blIndex = blVi
					exit
				)
			)
									
			if blIndex == 0 then
			(	-- �����������޴˶���
				newblVert =  blVertexData()
				
				newblVert.vertex = vert
				newblVert.uv = uv				
				newblVert.weights = weights
				newblVert.boneIndexs = boneIndexs
				newblVert.boneOffsets = boneOffsets
				
				append blVertices newblVert
				blIndex = blVertices.count	
			)
			else
			(	-- �����������д˶�����
			
			)
			append blIndices (blIndex-1)
		)
		-- ���鶥�㲻���غ�
		dis1 = vdistance v1 v2
		dis2 = vdistance v1 v3
		dis3 = vdistance v2 v3
		--format "face=% v1=% v2=% v3=% d12=% d13=% d23=%\n" fi v1 v2 v3 dis1 dis2 dis3
		if dis1 < 0.01 or dis2 < 0.01 or dis3 < 0.01 do
		(
			format "mesh:%�ĵڸ�%�����غ϶���% % %\n " mesh.name fi v1 v2 v3 to:errString
		)		
	)
	
	
	-- �����������������
	if isBinary then
	(
		WriteLong file 2 unsigned		-- �汾��
		WriteLong file blVertices.count 	-- ������
		WriteLong file faceNum  		-- ����
		WriteLong file blIndices.count	-- ������
		
		-- vertex����chunk
		WriteShort file chunkid_blm_vertex unsigned
		WriteLong file blVertices.count unsigned
		
		-- vertex����		
		for vi=1 to blVertices.count do
		(			
			-- ����λ��
			WriteFloat file blVertices[vi].vertex[1]
			WriteFloat file blVertices[vi].vertex[3]
			WriteFloat file blVertices[vi].vertex[2]
			-- uv
			WriteFloat file blVertices[vi].uv[1]
			WriteFloat file (1-blVertices[vi].uv[2])
			-- ����Ȩ����
			WriteByte file (blVertices[vi].weights.count) unsigned
			-- ����Ȩ��
			for bi=1 to blVertices[vi].weights.count do
			(
				WriteShort file (blVertices[vi].boneIndexs[bi]-1)
				WriteFloat file blVertices[vi].weights[bi]
			)
		)
		
		-- index����chunk
		WriteShort file chunkid_blm_index unsigned
		WriteLong file faceNum unsigned

		-- index����
		for fi=1 to faceNum  do
		(
			WriteLong file blIndices[fi*3] unsigned
			WriteLong file blIndices[fi*3-1] unsigned
			WriteLong file blIndices[fi*3-2] unsigned
		)
	)
	else
	(
		format "animation %%\n" (getFilenameFile avatarFileName) (getFilenameType avatarFileName) to:file
		format "vertexNum %\n" blVertices.count to:file
		format "faceNum %\n" faceNum to:file
		format "indexNum %\n" blIndices.count to:file
		format "\n" to:file
		
		format "vertices {\n" to:file
		for vi=1 to blVertices.count do
		(
			format "\tv % {\n" (vi-1) to:file
			-- ����λ��
			format "\t\t% % %\n" \
				blVertices[vi].vertex[1] blVertices[vi].vertex[3] blVertices[vi].vertex[2] to:file -- λ��
			-- uv
			format "\t\t% %\n" blVertices[vi].uv[1] (1-blVertices[vi].uv[2]) to:file
			-- ����Ȩ����
			format "\t\t%\n" (blVertices[vi].weights.count) to:file
			for bi=1 to blVertices[vi].weights.count do
			(
				-- ������� Ȩ�� offset
	--			format "\t\t% % % % %\n" \
	--			(blVertices[vi].boneIndexs[bi]-1) blVertices[vi].weights[bi] \
	--			blVertices[vi].boneOffsets[bi].x blVertices[vi].boneOffsets[bi].z blVertices[vi].boneOffsets[bi].y\
	--			to:file
				format "\t\t% %\n" \
				(blVertices[vi].boneIndexs[bi]-1) blVertices[vi].weights[bi] \
				to:file
	
			)
				
			format "\t}\n" to:file
		)
		format "}\n" to:file
		
		format "indices {\n" to:file
		for fi=1 to faceNum  do
		(	-- ����
			format "\t% % %\n" blIndices[fi*3] blIndices[fi*3-1] blIndices[fi*3-2] to:file
		)
		format "}\n" to:file
	)
)
-- ����ÿ��ģ�͵��ļ�
function ExportMeshs savePath =
(
	for mi=1 to mesh_array.count do
	(
		progress( 70 + (20 * mi / mesh_array.count) )	-- ������
		mesh = mesh_array[mi]
		meshFileName = savePath + mesh.name + ".blm"
		format "����ģ���ļ� %\n" meshFileName 
		if isBinary then
			meshFile = fopen meshFileName "wb"
		else
			meshFile = createfile meshFileName 	-- ����ģ���ļ�
		try
		(
			if isBinary then
			(
				ExportMesh mesh meshFile
			)
			else
			(
				meshString = stringstream""
				ExportMesh mesh meshString 
				format "%" (meshString as string) to:meshFile 
			)
		)
		catch
		(
			format "����ģ�� �쳣!\n"
			messageBox "����ģ�ͷ�������!" title:"��������"
		)
		if isBinary then
			fclose meshFile 
		else
			close meshFile 
		format "�ر�ģ���ļ�\n"
		
		-- ������һ��ģ�͵���ͼ,��������ͼ
		--if mi==1 then
		--(
		--	TextureExport mesh
		--)
	)
)
-- ��������
function ExportAnim fileName =
(
	isOk = true
	avatarFileName = fileName
	savePath = getFilenamePath avatarFileName
	
	-- ����avatar�ļ�������avatar�������ļ�)
	if isExportBla do
	(
		format "����avatar�ļ� %\n" avatarFileName 
		if isBinary then
			avatarFile = fopen (lowercase avatarFileName) "wb"
		else
			avatarFile = createfile avatarFileName 	-- ����avatar�ļ�
		try
		(
			set time baseFrame
			if isBinary then
			(
				WriteAniHeader avatarFile		-- �ļ�ͷ
				WriteBoneHierarchy avatarFile	-- ������ϵ
				WriteBonePosition avatarFile	-- ��������
				--WriteHelper avatarFile			-- �����󶨵�
			)
			else
			(
				avatarString = stringstream""
				WriteAniHeader avatarString 		-- �ļ�ͷ
				WriteBoneHierarchy avatarString -- ������ϵ
				WriteBonePosition avatarString -- ��������
				--WriteHelper avatarString 	-- �����󶨵�
				format "%" (avatarString as string) to:avatarFile 
			)
		)
		catch
		(
			format "����avatar�ļ� �쳣!\n"
			messageBox "����ʱ��������!" title:"��������"
			isOk = false
		)
		if isBinary then
			fclose avatarFile
		else
			close avatarFile 
		format "�رն����ļ�\n"
		if isOk == false then return undefined
	)
	
	-- ���������󶨵��ļ�
	if isExportBlt do
	(
		-- ���������󶨵��ļ�
		tagFileName = savePath + (getFilenameFile avatarFileName) + ".blt"
			
		if isBinary then
			tagFile = fopen tagFileName "wb"
		else
			tagFile = createfile tagFileName 
			
		try
		(
			if isBinary then
			(
				WriteHelper tagFile			-- �����󶨵�
			)
			else
			(
				tagString = stringstream""
				WriteHelper tagString 	-- �����󶨵�
				format "%" (tagString as string) to:tagFile 
			)
		)
		catch
		(
			format "���������󶨵��ļ� �쳣!\n"
			messageBox "����ʱ��������!" title:"��������"
			isOk = false
		)
		if isBinary then
			fclose tagFile 
		else
			close tagFile 
			
		format "�رչ����󶨵��ļ�\n"
		if isOk == false then return undefined
	)
	
	
	-- ���������ļ�
	if isExportBlq do
	(
		tagsNum = FrameTagManager.GetTagCount()	-- ����timetag����		
		if tagsNum == 0 then format "û������Time Tag\n" to:errString 
		tagsPairNum = tagsNum / 2
		for pi = 1 to tagsPairNum do
		(
			CrownExport.progExport.value =  20 + (50 * pi / tagsPairNum )	-- ������
			
			tagId = FrameTagManager.GetTagID (pi*2-1)
			tagId2 = FrameTagManager.GetTagID (pi*2)
			tagName = FrameTagManager.GetNameByID tagId
			tagTime = FrameTagManager.GetTimeByID tagId
			tagTime2 = FrameTagManager.GetTimeByID tagId2
	
			tagTimeStr = tagTime as string
			tagTime2Str = tagTime2 as string
			t1 = (substring tagTimeStr 1 (tagTimeStr.count-1)) as number
			t2 = (substring tagTime2Str 1 (tagTime2Str.count-1)) as number
			tagName = filterSpace tagName 
			format "����(%) [%, %]\n" tagName t1 t2
			
			-- ���������ļ�
			aniFileName = savePath + tagName + ".blq"
			
			if isBinary then
				aniFile = fopen aniFileName "wb"
			else
				aniFile = createfile aniFileName
			
			try
			(
				if isBinary then
				(
					WriteBoneAnimation aniFile tagName t1 t2
				)
				else
				(
					aniString = stringstream""
					WriteBoneAnimation aniString tagName t1 t2	-- ������������
					format "%" (aniString as string) to:aniFile
				)			
			)
			catch
			(			
				format "��������%�쳣! %\n" tagName (getCurrentException())
				messageBox "����ʱ��������!\n" title:"��������"
				isOk = false
			)
			
			if isBinary then
				fclose aniFile 
			else
				close aniFile 

			format "�رն����ļ�%\n" tagName
			if isOk == false then return undefined
	
		)
	)
	
	-- ����ģ���ļ�
	if isExportBlm do
	(
		format "����ģ���ļ���Ŀ¼ %\n" savePath
		set time baseFrame
		ExportMeshs savePath
		format "����ģ�����\n"
	)
		
)
-- �������
function main =
(
	format "main start\n"
	-- �������
	mesh_array.count = 0
	bone_array.count = 0
	helper_array.count = 0
	errString = stringstream""
	-- ָ�������ļ�
	if (CrownExport.fileNameEditor.text.count > 0) then
	(
		avatarFileName = CrownExport.fileNameEditor.text
	)
	else
	(
		avatarFileName = "avatar.bla"		
	)
	
	avatarFileName = getsavefilename caption:"�����ɫ" \
			filename:avatarFileName \
			types:"Crown AvatarFile (*.bla)|*.bla|All Files (*.*)|*.*|"
		if avatarFileName == undefined then return undefined
	
	CrownExport.fileNameEditor.text = avatarFileName
	
	format "���浽 %\n" avatarFileName 
	
	clearSelection()
	format "����=% ģ��=% ����=%\n" isExportBla isExportBlm isExportBlq
	-- ������ݺϷ���
	isOk = SkinCheck()
	-- ��ʼ����	
	if isOk or isSkinCheck==false then
	(	
		ExportAnim(avatarFileName)		
	)
	clearSelection()
	
	-- ת������tagΪblt
	--thisMaxScriptDir = getSourceFileName()
	--thisMaxScriptDir = getFilenamePath thisMaxScriptDir 
	--commandStr = thisMaxScriptDir + "ConvertTgaToBlt.exe " + (getFilenamePath avatarFileName)
	--format "DOS:%\n" commandStr 			
	--DOSCommand commandStr 
		
	-- �������
	if ((errString as string).count > 0)  then
	(
		format "���󱨸�\n"
		format "%" (errString as string)
		messageBox (errString as string) title:"����!"
	)
	
	format "main end\n"
)

function trymain = 
(
	try
	(
		main()		
	)
	catch
	(
		exceptionString = stringstream""
		format "����ʱ��������!\n*** % ***\n" (getCurrentException()) to:exceptionString
		messageBox (exceptionString as string) title:"����!"
	)
)

-- ����
rollout CrownExport "Crown����������������2.4.23��" width:205 height:500
(
	button btnExport "��������" width:85 height:20
	
	checkbox exportHide "Checkbox" pos:[40,32] width:16 height:16 checked:false
	label lbl1 "������������" pos:[55,32] width:112 height:16
	
	checkbox exportKeyFrame "Checkbox" pos:[40,50] width:16 height:16 checked:true
	label lbl2 "���ؼ�֡����" pos:[55,50] width:112 height:16
	
	checkbox exportNoBinary "Checkbox" pos:[0,70] width:16 height:16 checked:(not isBinary)
	label lbl9 "�ı���ʽ����" pos:[15,70] width:112 height:16
	
	checkbox exportCheckSkin "Checkbox" pos:[100,70] width:16 height:16 checked:isSkinCheck
	label lbl11 "skin���" pos:[115,70] width:112 height:16

	checkbox exportBla "Checkbox" pos:[5,90] width:16 height:16 checked:isExportBla enabled:true
	label lbl6 "����" pos:[20,90] width:112 height:16
	
	checkbox exportBlt "Checkbox" pos:[50, 90] width:16 height:16 checked:isExportBlt enabled:true
	label lbl10 "�󶨵�" pos:[65, 90] width:112 height:16
	
	checkbox exportBlm "Checkbox" pos:[100,90] width:16 height:16 checked:isExportBlm
	label lbl7 "ģ��" pos:[115,90] width:112 height:16

	checkbox exportBlq "Checkbox" pos:[140,90] width:16 height:16 checked:isExportBlq
	label lbl8 "����" pos:[155,90] width:112 height:16
	
	label lbl4 "�����ļ���" pos:[10,110] width:172 height:16
	edittext fileNameEditor "" pos:[2,130] width:170 height:16 
	
	label lbl3 "����֡��(ÿ��֡����һ֡)" pos:[10,150] width:152 height:16 enabled:false
	spinner spn3 "" pos:[20,170] width:48 height:16 range:[1,10,5] type:#integer scale:1 enabled:false
		
	button btnTagList "���¶����б�" pos:[30,190] width:100 height:20 enabled:false
	label lbl5 "���¶������ؼ�֡����" pos:[10,210] width:152 height:16 enabled:false
	listbox animList "" pos:[5, 230] width:148 height:15 enabled:false
	
	progressbar progExport color:blue visible:false
	
	
	on btnExport pressed do
	(
		progExport.visible = true
		isExportHide = exportHide.checked
		isExportKeyFrame = exportKeyFrame.checked
		frameSampleRate = spn3.value as integer
		format "isExportHide=% isExportKeyFrame=% frameSampleRate=%\n" \
			isExportHide isExportKeyFrame frameSampleRate 
			
		CrownExport.progExport.value = 0		-- ������
		trymain()
		CrownExport.progExport.value = 100
		progExport.visible = false
		
	)
	
	on exportKeyFrame changed theState do
	(
		if theState then
		(
			spn3.enabled = false
			lbl3.enabled = false
			btnTagList.enabled = false
			lbl5.enabled = false
			animList.enabled = false
		)
		else
		(
			spn3.enabled = true
			lbl3.enabled = true
			btnTagList.enabled = true
			lbl5.enabled = true
			animList.enabled = true
		)			
	)
	
	on exportCheckSkin changed theState do
	(
		isSkinCheck = theState		
	)
	
	on exportNoBinary changed theState do
	(
		isBinary = not theState
	)
	
	on exportBla changed theState do
	(
		isExportBla = theState
		if isExportBla then
		(
			isExportBlq = not theState
			exportBlq.checked = isExportBlq 
		)
	)
	
	on exportBlt changed theState do
	(
		isExportBlt = theState
		if isExportBlt then
		(
			isExportBlq = not theState
			exportBlq.checked = isExportBlq 
		)
	)
	
	on exportBlm changed theState do
	(
		isExportBlm = theState
		if isExportBlm then
		(
			isExportBlq = not theState
			exportBlq.checked = isExportBlq 		
		)
	)
	
	on exportBlq changed theState do
	(
		isExportBlq = theState
		if isExportBlq then
		(
			isExportBla = not theState
			exportBla.checked = isExportBla 
			isExportBlm = not theState
			exportBlm.checked = isExportBlm
			isExportBlt = not theState
			exportBlt.checked = isExportBlt
		)

	)
	
	on btnTagList pressed do
	(
		CrownExport.animList.items.count = 0
		
		tagNames = #()
		tagsNum = FrameTagManager.GetTagCount()
		tagsPairNum = tagsNum / 2
		for pi = 1 to tagsPairNum do
		(
			tagId = FrameTagManager.GetTagID (pi*2-1)
			tagId2 = FrameTagManager.GetTagID (pi*2)
			tagName = FrameTagManager.GetNameByID tagId
			tagName = filterSpace tagName
			append tagNames tagName 
		)
		CrownExport.animList.items = tagNames
	)
	
	on animList doubleClicked item do
	(
		temp = CrownExport.animList.items
		deleteItem temp item 
		CrownExport.animList.items = temp
	)
)
-- �����Ի���
if CrownExportFloater != undefined do
(	-- ���¶Ի���
	closerolloutfloater CrownExportFloater 
)
-- ����һ��RolloutFloater(�Ի���)
CrownExportFloater = newRolloutFloater "������������" 210 500 (mouse.screenpos[1]-85) (mouse.screenpos[2]-60)
addRollout CrownExport CrownExportFloater 	-- ����rollout���Ի�����

