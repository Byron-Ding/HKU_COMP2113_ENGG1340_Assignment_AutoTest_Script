#！/bin/bash

# 注意这里所有的路径全部都是相对于本脚本的路径
# 本脚本由 BEng B24 Byron Ding 编写

cpp_compile_setting_command="g++ -pedantic-errors -std=c++11"
c_compile_setting_command="gcc -pedantic-errors -std=c11"

my_cpp_files_path_folder="./my_codes/"
list_all_my_cpp_files_command="ls "${my_cpp_files_path_folder}
# echo $list_all_my_cpp_files_command
# 正则表达式，筛选符合条件的文件，一位数字，然后以c或cpp结尾
my_cpp_files="`${list_all_my_cpp_files_command} | grep -E \"^[0-9]\.c(pp)?$\"`"
# echo $my_cpp_files

# 因为是按照文件名来测试的，所以不用担心多余的遍历从而报错
for my_c_cpp_file in ${my_cpp_files}
do
	# 切割字符串，从零开始，一位
	file_number=${my_c_cpp_file:0:1}
	
	# 后缀
	# -d 改变分隔符，-f截取第二个部分（最后一个部分）
	file_format=`echo ${my_c_cpp_file} | cut -d "." -f 2`

	# 编译自己的文件
	# 如果是c++
	if [ ${file_format} == "cpp" ]
	then
		complie_command=${cpp_compile_setting_command}" "${my_cpp_files_path_folder}${my_c_cpp_file}" -o "${my_cpp_files_path_folder}${file_number}".exe"
	# 如果是c
	elif [  ${file_format} == "c"  ]
	then
		complie_command=${c_compile_setting_command}" "${my_cpp_files_path_folder}${my_c_cpp_file}" -o "${my_cpp_files_path_folder}${file_number}".exe"
	fi
	
	# 编译
	`${complie_command}`
	# 找到对应的测试文件夹
	corresponding_folder_path="./p"${file_number}"/sample_test_cases/"

	# 找到对应的文件夹 并拼接命令
	test_files_foder_path_command="ls "${corresponding_folder_path}
	# 获取所有在对应的文件夹下对应的测试文件
	all_test_files="`${test_files_foder_path_command}`"

	# 获取一共有多少测试文件
	number_of_input_and_output_files=`ls -l ${corresponding_folder_path} | grep "^-" | grep "input" | wc -l`
	# echo $file_numbers
	# 已经废除 # 其中一半是输入，一半是输出
	
	# echo $number_of_input_and_output_files
	# 循环测试文件
	index=1
	while ((${index} <= $number_of_input_and_output_files))
	do
		#echo $index
		# 每一个自己输出的文件的文件名（文件路径）
		each_myoutput_path=${corresponding_folder_path}"myoutput"${index}".txt"

		# 如果自己的文件不存在，创建文件
		if [ -e ${each_myoutput_path} ]
		then
			touch ${each_myoutput_path}
		fi
		# input 的文件名
		each_input_file_name="input"${file_number}"_"${index}".txt"
		
		# output 的文件名
		each_output_file_name="output"${file_number}"_"${index}".txt"
		
		# input 的文件名 （文件路径）
		each_input_file_path="${corresponding_folder_path}${each_input_file_name}"
		
		# output 的文件名 （文件路径）
		each_output_file_path="${corresponding_folder_path}${each_output_file_name}"

		# 可执行文件路径
		excute_file_path=${my_cpp_files_path_folder}${file_number}".exe"
		# 输入文件到可执行文件，输出结果储存到自己的文件
		${excute_file_path} < ${each_input_file_path} > ${each_myoutput_path}
		
		# echo $each_myoutput_path
		temp="diff "${each_output_file_path}" "${each_myoutput_path}
		
		# echo $temp
		# diff "${each_output_file_path}" "${each_myoutput_path}"
		complie_command="diff "${each_output_file_path}" "${each_myoutput_path}
		
		compare_result=`${complie_command}`
		
		# 打印文件名 input output
		# -e 开启特殊字符转义
		# …… 会自动转成中文的省略号
		echo -e "正在测试中……"
		echo -e "需要编译的文件："${my_c_cpp_file}
		echo -e "\t样例输入文件："${each_input_file_name}
		echo -e "\t样例输出文件："${each_output_file_name}
		# 打印结果
		echo "结果如下："
		echo $compare_result
		# 打印结果是否为空
		echo "结果是否为空："
		if [ "${compare_result}" == "" ]
		then
			echo -e "\tempty：True"
		fi
		# 分割题目打印结果
		echo "——————————————————————"
		# if [ "${compare_result}" == "" ]
		# then
		# 	echo "true"
		# fi
		let "index++"
	done
	# 打印横线，这样，每个c/cpp文件测试完成之后会用双横线分割（包括前面的横线）
	echo "——————————————————————"
done

