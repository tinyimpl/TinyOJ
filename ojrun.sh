#!/usr/bin/env bash
# this file is created by tinyimpl on 2023/04/27
# require: echo, test, grep, sed, mktemp, diff

input_flag="INPUT"
output_flag="OUTPUT"
end_flag="END"
# check the args num
if [ $# != "2" ]; then
    echo "how to use: $0 program test_file"
    echo "example: $0 ./a.out test.txt"
    exit 1
fi

program=$1
test_file=$2

if ! test -x "${program}";then
    echo -e "\e[1;31mError: program can not exec, program is ""${program}"""
    exit 1
fi

if ! test -r "${test_file}";then
    echo -e "\e[1;31mError: test file can not read, test file is ""${test_file}"""
    exit 1
fi

input_flag_lines=$(grep -c "^${input_flag}$" "${test_file}")
output_flag_lines=$(grep -c "^${output_flag}$" "${test_file}")
end_flag_lines=$(grep -c "^${end_flag}$" "${test_file}")

# check the test file
if [ "${input_flag_lines}" == "${output_flag_lines}" ] && [ "${input_flag_lines}" == "${end_flag_lines}" ]; then
    tmp_input_file=$(mktemp)
    tmp_output_file=$(mktemp)
    tmp_program_output_file=$(mktemp)
    line_id=1
    case_id=1
    while read -r line
    do
        if [[ "$line" == "INPUT" ]]; then
            input_start=${line_id}
            elif [[ "$line" == "OUTPUT" ]]; then
            input_end=${line_id}
            output_start=${line_id}
            elif [[ "$line" == "END" ]]; then
            output_end=${line_id}
            # run program
            $(sed -n "$((input_start+1)), $((input_end-1))p" "${test_file}" > "${tmp_input_file}")
            $(sed -n "$((output_start+1)), $((output_end-1))p" "${test_file}" > "${tmp_output_file}")
            $(${program} < "${tmp_input_file}" > "${tmp_program_output_file}")
            # check result
            if diff "${tmp_program_output_file}" "${tmp_output_file}" > /dev/null; then
                echo -e "\e[1;32mPass: pass case ${case_id}, ^v^"
                ((case_id++))
            else
                echo -e "\e[1;31mFail: fail to pass case ${case_id}, ToT"
                echo -e "\e[1;36mInput:"
                cat ${tmp_input_file}
                echo -e "\e[1;36mAssert Output:"
                cat ${tmp_output_file}
                echo -e "\e[1;31mYour Output:"
                cat ${tmp_program_output_file}
                mv "${tmp_program_output_file}" your_output.tmp
                mv "${tmp_output_file}" assert_output.tmp
                mv "${tmp_input_file}" input.tmp
                exit 1
            fi
        fi
        ((line_id++))
    done < "${test_file}"
    rm "${tmp_program_output_file}"
    rm "${tmp_output_file}"
    rm "${tmp_input_file}"
    echo -e "\e[1;32mPass: pass all test case!!!"
else
    echo -e "\e[1;31mError: illgal test file, file is ""${test_file}"""
    exit 1
fi

