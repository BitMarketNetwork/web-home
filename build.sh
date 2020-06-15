#!/bin/bash -e
if [[ "$(realpath -s "${0}")" =~ [[:blank:]] ]]; then echo "Can't run ${0} with spaces in path."; exit 1; fi

project_dir=$(dirname $(realpath -s ${0}))
source_dir=${project_dir}/src
output_dir=${project_dir}/build
minify=${project_dir}/3rdparty/minify_2.5.2_linux_amd64/minify

if [[ -z ${project_dir} ]]
then
    echo 'Invalid shell environment.' >&2
    exit 1
fi

pack_file()
{
    source_type=${1}
    source_file=${2}
    source_file_dir=$(dirname ${source_file})

    output_file=$(realpath --relative-to ${source_dir} ${source_file})
    output_file=${output_dir}/${output_file}
    output_file_dir=$(dirname ${output_file})

    echo -e "\n-> ${output_file}"
    mkdir -p ${output_file_dir} || return 1

    case ${source_type} in
    css)
        ${minify} -v --type css \
            --css-decimals -1 \
            -o ${output_file} \
            ${source_file} \
        || return 1
        ;;
    svg)
        ${minify} -v --type svg \
            --svg-decimals -1 \
            -o ${output_file} \
            ${source_file} \
        || return 1
        ;;
    js)
        ${minify} -v --type js \
            -o ${output_file} \
            ${source_file} \
        || return 1
        ;;
    html)
        ${minify} -v --type html \
            --html-keep-conditional-comments \
            --html-keep-default-attrvals \
            --html-keep-document-tags \
            --html-keep-end-tags \
            -o ${output_file} \
            ${source_file} \
        || return 1
        ;;
    font|gif|png|ico|jpeg)
        cp -Lv \
            --preserve=timestamps \
            ${source_file} \
            ${output_file} \
        || return 1
        ;;
    *)
        echo "Unknown type \"${source_type}\"." >&2
        return 1
        ;;
    esac

    touch -cr ${source_file} ${output_file} || return 1
    touch -cr ${source_file_dir} ${output_file_dir} || return 1

    return 0
}

pack_all()
{
    local type=${1}
    (find ${source_dir} -type f -name ${2} -print0 |
        while IFS= read -r -d '' f
        do
            pack_file ${1} ${f} || return 1
        done
    ) \
    || return 1

    return 0
}

if [[ -e ${output_dir} ]]
then
    rm -rf ${output_dir}
    mkdir -p ${output_dir}
fi

pack_all css  '*.css'
pack_all svg  '*.svg'
pack_all gif  '*.gif'
pack_all png  '*.png'
pack_all ico  '*.ico'
pack_all jpeg '*.jpg'
pack_all js   '*.js'
pack_all html '*.html'
pack_all font '*.eot'
pack_all font '*.ttf'
pack_all font '*.woff'
pack_all font '*.woff2'

find ${output_dir}/ -type f -exec chmod 0644 {} \;
find ${output_dir}/ -type d -exec chmod 0755 {} \;

ln -vs index-en.html ${output_dir}/index.html

echo -e "\nBUILD SUCCESSFUL"
exit 0
