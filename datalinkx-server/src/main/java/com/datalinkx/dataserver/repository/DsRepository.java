package com.datalinkx.dataserver.repository;

import com.datalinkx.dataserver.bean.domain.DsBean;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;



@Repository
public interface DsRepository extends CRUDRepository<DsBean, String> {

	Optional<DsBean> findByDsId(String dsId);

	List<DsBean> findAllByIsDel(Integer isDel);

	@Query(value = "select * from DS where name = :name and is_del = 0", nativeQuery = true)
	DsBean findByName(String name);

	List<DsBean> findAllByDsIdIn(List<String> dsIds);

	@Query(value = "SELECT * FROM DS WHERE is_del = 0 " +
			"AND (:name IS NULL OR name LIKE CONCAT('%', :name, '%')) " +
			"AND (:type IS NULL OR type = :type)", nativeQuery = true)
    Page<DsBean> pageQuery(Pageable pageable, String name, Integer type);

	@Transactional
	@Modifying
	@Query(value = "update DS set is_del = 1 where ds_id = :dsId", nativeQuery = true)
	void deleteByDsId(String dsId);
}
