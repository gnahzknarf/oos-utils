create or replace package body oos_util_lob
as

  -- ******** PUBLIC ********

  /**
   * Convers clob to blob
   *
   * Notes:
   *  -
   *
   * Related Tickets:
   *  - #12
   *
   * @author Moritz Klein (https://github.com/commi235)
   * @created 07-Sep-2015
   * @param p_clob Clob to conver to blob
   * @return blob
   */
  function clob2blob(
    p_clob in clob)
    return blob
  as
    l_blob blob;
    l_dest_offset integer := 1;
    l_src_offset integer := 1;
    l_warning integer;
    l_lang_ctx integer := dbms_lob.default_lang_ctx;
  begin
    dbms_lob.createtemporary(l_blob, false, dbms_lob.session );
    dbms_lob.converttoblob(
      l_blob,
      p_clob,
      dbms_lob.lobmaxsize,
      l_dest_offset,
      l_src_offset,
      dbms_lob.default_csid,
      l_lang_ctx,
      l_warning);
    return l_blob;
  end clob2blob;

  /**
   * Converts blob to clob
   *
   * Notes:
   *  - Copied from http://stackoverflow.com/questions/12849025/convert-blob-to-clob
   *
   * Related Tickets:
   *  - #1
   *
   * @author Martin D'Souza
   * @created 02-Mar-2014
   * @param p_blob blob to be converted to clob
   * @return clob
   */
  function blob2clob(
    p_blob in blob)
    return clob
  as
    l_clob clob;
    l_dest_offsset integer := 1;
    l_src_offsset integer := 1;
    l_lang_context integer := dbms_lob.default_lang_ctx;
    l_warning integer;

  begin
    if p_blob is null then
      return null;
    end if;

    dbms_lob.createTemporary(
      lob_loc => l_clob,
      cache => false);

    dbms_lob.converttoclob(
      dest_lob => l_clob,
      src_blob => p_blob,
      amount => dbms_lob.lobmaxsize,
      dest_offset => l_dest_offsset,
      src_offset => l_src_offsset,
      blob_csid => dbms_lob.default_csid,
      lang_context => l_lang_context,
      warning => l_warning);

    return l_clob;
  end blob2clob;



  /**
   * Returns human readable file size
   *
   * Notes:
   *  -
   *
   * Related Tickets:
   *  - #6
   *
   * @author Martin D'Souza
   * @created 07-Sep-2015
   * @param p_file_size size of file in bytes
   * @return Human readable file size
   */
  -- TODO mdsouza: rename to get_h_file_size?
  function get_file_size(
    p_file_size in number,
    p_units in varchar2 default null)
    return varchar2
  as
    l_units varchar2(255);
  begin
    -- List of formats: http://www.gnu.org/software/coreutils/manual/coreutils
    l_units := nvl(p_units,
      case
        when p_file_size < 1024 then oos_util_lob.gc_unit_b
        when p_file_size < power(1024,2) then oos_util_lob.gc_unit_kb
        when p_file_size < power(1024,3) then oos_util_lob.gc_unit_mb
        when p_file_size < power(1024,4) then oos_util_lob.gc_unit_gb
        when p_file_size < power(1024,5) then oos_util_lob.gc_unit_tb
        when p_file_size < power(1024,6) then oos_util_lob.gc_unit_pb
        when p_file_size < power(1024,7) then oos_util_lob.gc_unit_eb
        when p_file_size < power(1024,8) then oos_util_lob.gc_unit_zb
        else
          oos_util_lob.gc_unit_yb
      end
    );

    return to_char(
      round(
        case
          when l_units = oos_util_lob.gc_unit_b then p_file_size
          when l_units = oos_util_lob.gc_unit_kb then p_file_size/1024
          when l_units = oos_util_lob.gc_unit_mb then p_file_size/power(1024,2)
          when l_units = oos_util_lob.gc_unit_gb then p_file_size/power(1024,3)
          when l_units = oos_util_lob.gc_unit_tb then p_file_size/power(1024,4)
          when l_units = oos_util_lob.gc_unit_pb then p_file_size/power(1024,5)
          when l_units = oos_util_lob.gc_unit_eb then p_file_size/power(1024,6)
          when l_units = oos_util_lob.gc_unit_zb then p_file_size/power(1024,7)
          else
            -- oos_util_lob.gc_unit_yb
            p_file_size/power(1024,8)
        end, 1)
      ,
      -- Number format
      '999G999G999G999G999G999G999G999G999' ||
        case
          when l_units != oos_util_lob.gc_unit_b then 'D9'
          else null
        end
    ) || ' ' || l_units;
  end get_file_size;

  function get_file_size(
    p_clob in clob,
    p_units in varchar2 default null)
    return varchar2
  as
  begin
    return get_file_size(
      p_file_size => dbms_lob.getlength(p_clob),
      p_units => p_units
    );
  end get_file_size;

  function get_file_size(
    p_blob in blob,
    p_units in varchar2 default null)
    return varchar2
  as
  begin
    return get_file_size(
      p_file_size => dbms_lob.getlength(p_blob),
      p_units => p_units
    );
  end get_file_size;

end oos_util_lob;
/