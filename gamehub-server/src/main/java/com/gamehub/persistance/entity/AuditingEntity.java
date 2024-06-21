package com.gamehub.persistance.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.CreatedBy;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedBy;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.io.Serializable;
import java.time.LocalDateTime;

@Getter
@Setter
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class AuditingEntity implements Serializable {
    @ManyToOne(fetch = FetchType.LAZY)
    @CreatedBy
    @JoinColumn(name = "created_by")
    protected UserEntity createdBy;

    @CreatedDate
    @Column(name = "created_on"/*TODO, nullable = false*/)
    protected LocalDateTime createdOn;

    @ManyToOne(fetch = FetchType.LAZY)
    @LastModifiedBy
    @JoinColumn(name = "updated_by")
    protected UserEntity updatedBy;

    @LastModifiedDate
    @Column(name = "updated_on")
    protected LocalDateTime updatedOn;

    @Version
    @Column(/*TODO nullable = false*/)
    protected long version;
}
